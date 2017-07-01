defmodule Pagination do
  defstruct [:page, :per_page, :total_pages, :total_count]

  import Fanuniverse.Utils, only: [parse_integer: 2]

  def struct(page, per_page, total_count) do
    total_pages =
      (total_count / per_page) |> Float.ceil() |> trunc()

    %Pagination{
      page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_count: total_count
    }
  end

  def extract_page_and_per_page(params, opts) do
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
end
