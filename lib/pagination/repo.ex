defmodule Pagination.Repo do
  @moduledoc """
  A mixin that defines the `paginate_es/5` function for an Ecto repo.
  """

  import Ecto.Query
  import Enum, only: [map: 2, find: 2, reject: 2]
  import Fanuniverse.Utils, only: [parse_integer: 2]

  alias Elasticfusion.Search, as: Elasticsearch
  alias Elasticfusion.Search.Builder, as: ElasticsearchQuery

  defmacro __using__(_) do
    quote do
      def paginate_es(es_query, es_index, queryable, params \\ %{}, opts \\ []) do
        Pagination.Repo.paginate_es(
          es_query, es_index, __MODULE__, queryable, params, opts)
      end
    end
  end

  def paginate_es(es_query, es_index, repo, queryable, params, opts) do
    {page, per_page} = extract_page_and_per_page(params, opts)

    es_response =
      es_query
      |> ElasticsearchQuery.paginate(page, per_page)
      |> Elasticsearch.find_ids(es_index)

    case es_response do
      {:ok, ids, total_count} ->
        pagination =
          Pagination.struct(page, per_page, total_count)
        records =
          get_by_ids_sorted(repo, queryable, ids)

        {:ok, pagination, records}
      error ->
        error
    end
  end

  defp extract_page_and_per_page(params, opts) do
    page = parse_integer(params["page"], 1)
    page = if page < 1, do: 1, else: page

    per_page = parse_integer(params["per_page"], opts[:default_per_page] || 10)
    per_page = if opts[:max_per_page] && per_page > opts[:max_per_page] do
      opts[:max_per_page]
    else
      per_page
    end

    {page, per_page}
  end

  defp get_by_ids_sorted(repo, query, ids) do
    records = repo.all(from(r in query, where: r.id in ^ids))

    ids
    |> map(fn(id) ->
         find(records, &(&1.id == parse_integer(id, nil)))
       end)
    |> reject(&is_nil/1)
  end
end
