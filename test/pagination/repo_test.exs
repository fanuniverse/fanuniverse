defmodule Pagination.RepoTest do
  use Fanuniverse.DataCase

  import Ecto.Query

  test "paginate/3" do
    records =
      for n <- 1..8, do: insert(:image, %{stars_count: n})
    record_ids =
      Enum.map(records, &(&1.id))
    query =
      from i in Fanuniverse.Image,
      where: i.id in ^record_ids,
      order_by: [asc: :stars_count]

    assert {:ok, pagination, page_records} =
      Repo.paginate(query, %{"page" => "2", "per_page" => "3"})
    assert pagination =
      %Pagination{page: 2, per_page: 3, total_pages: 3, total_count: 8}
    assert [4, 5, 6] ==
      Enum.map(page_records, &(&1.stars_count))

    empty_query =
      from(i in Fanuniverse.Image, where: i.stars_count == 9000)

    assert {:ok, pagination, page_records} =
      Repo.paginate(empty_query, %{"page" => "2", "per_page" => "3"})
    assert pagination =
      %Pagination{page: 2, per_page: 3, total_pages: 0, total_count: 0}
    assert [] = page_records
  end
end
