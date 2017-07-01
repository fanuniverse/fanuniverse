defmodule Pagination do
  defstruct [:page, :per_page, :total_pages, :total_count]

  def struct(page, per_page, total_count) do
    total_pages =
      (total_count / per_page) |> Float.ceil() |> Kernel.trunc()

    %Pagination{
      page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_count: total_count
    }
  end
end
