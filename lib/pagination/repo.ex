defmodule Pagination.Repo do
  @moduledoc """
  A mixin that defines the `paginate_es/5` function for an Ecto repo.
  """

  import Ecto.Query
  import Enum, only: [map: 2, find: 2, reject: 2]
  import Fanuniverse.Utils, only: [parse_integer: 2]
  import Pagination, only: [extract_page_and_per_page: 2]

  alias Elasticfusion.Search, as: Elasticsearch
  alias Elasticfusion.Search.Builder, as: ElasticsearchQuery

  defmacro __using__(_) do
    quote do
      def paginate_es(es_query, es_index, queryable, params \\ %{}, opts \\ []) do
        Pagination.Repo.paginate_es(
          es_query, es_index, __MODULE__, queryable, params, opts)
      end

      def paginate(queryable, params \\ %{}, opts \\ []) do
        Pagination.Repo.paginate(
          __MODULE__, queryable, params, opts)
      end

      def get_by_ids_sorted(queryable, ids) do
        Pagination.Repo.get_by_ids_sorted(
          __MODULE__, queryable, ids)
      end
    end
  end

  # Based on https://github.com/elixirdrops/kerosene/blob/master/lib/kerosene.ex
  def paginate(repo, queryable, params, opts) do
    {page, per_page} =
      extract_page_and_per_page(params, opts)
    total_count =
      total_count(repo, queryable)
    pagination =
      Pagination.struct(page, per_page, total_count)

    paginate(repo, queryable, pagination)
  end
  def paginate(repo, queryable, %Pagination{total_count: 0} = pagination),
    do: {:ok, pagination, []}
  def paginate(repo, queryable, %Pagination{
      page: page, per_page: per_page, total_count: total_count} = pagination) do
    max_pages =
      (total_count / per_page) |> Float.ceil() |> trunc()
    page =
      min(page, max_pages)
    offset =
      per_page * (page - 1)

    records =
      queryable
      |> limit(^per_page)
      |> offset(^offset)
      |> repo.all

    {:ok, pagination, records}
  end

  defp total_count(repo, queryable) do
    basic_query =
      queryable
      |> exclude(:preload)
      |> exclude(:order_by)
      |> exclude(:select)

    {_, schema} = basic_query.from
    primary_key = List.first(schema.__schema__(:primary_key))

    basic_query
    |> select([r], count(field(r, ^primary_key)))
    |> repo.one
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

  def get_by_ids_sorted(repo, query, ids) do
    records = repo.all(from(r in query, where: r.id in ^ids))

    ids
    |> map(fn(id) ->
         find(records, &(&1.id == parse_integer(id, nil)))
       end)
    |> reject(&is_nil/1)
  end
end
