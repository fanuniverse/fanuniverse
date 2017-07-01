defmodule Pagination.HTMLTest do
  use ExUnit.Case

  import Pagination.HTML, only: [
    render_pagination: 4, render_pagination_links: 3]
  import Fanuniverse.Web.Router.Helpers, only: [image_path: 3]

  test "pagination block" do
    assert render_block("images", %Pagination{
      page: 2, total_pages: 2, per_page: 9, total_count: 14}) ==
      [
        ~s(<div class="block flex">),
          ~s(<div class="flex__main">),
            ~s(<nav class="pagination">),
              ~s(<a class="page" href="/">«</a>),
              ~s(<a class="page" href="/" rel="prev">‹</a>),
              ~s(<a class="page" href="/" rel="prev">1</a>),
              ~s(<span class="current-page">2</span>),
            ~s(</nav>),
          ~s(</div>),
          ~s(<div class="flex__right">),
            ~s(Showing images 10-14 out of 14),
          ~s(</div>),
        ~s(</div>)
      ] |> to_string
  end

  test "single page" do
    assert render(%Pagination{page: 1, total_pages: 1}) ==
      ~s(<span class="current-page">1</span>)
  end

  test "first/last/prev/next arrows" do
    assert render(%Pagination{page: 2, total_pages: 3}) ==
      [
        ~s(<a class="page" href="/">«</a>),
        ~s(<a class="page" href="/" rel="prev">‹</a>),
        ~s(<a class="page" href="/" rel="prev">1</a>),
        ~s(<span class="current-page">2</span>),
        ~s(<a class="page" href="/?page=3" rel="next">3</a>),
        ~s(<a class="page" href="/?page=3" rel="next">›</a>),
        ~s(<a class="page" href="/?page=3">»</a>)
      ] |> to_string
  end

  test "page gaps" do
    assert render(%Pagination{page: 5, total_pages: 9}) ==
      [
        ~s(<a class="page" href="/">«</a>),
        ~s(<a class="page" href="/?page=4" rel="prev">‹</a>),
        ~s(<span class="page-gap">…</span>),
        ~s(<a class="page" href="/?page=3">3</a>),
        ~s(<a class="page" href="/?page=4" rel="prev">4</a>),
        ~s(<span class="current-page">5</span>),
        ~s(<a class="page" href="/?page=6" rel="next">6</a>),
        ~s(<a class="page" href="/?page=7">7</a>),
        ~s(<span class="page-gap">…</span>),
        ~s(<a class="page" href="/?page=6" rel="next">›</a>),
        ~s(<a class="page" href="/?page=9">»</a>)
      ] |> to_string
  end

  test "does not insert page gaps for a single page" do
    assert render(%Pagination{page: 4, total_pages: 7}) ==
      [
        ~s(<a class="page" href="/">«</a>),
        ~s(<a class="page" href="/?page=3" rel="prev">‹</a>),
        ~s(<a class="page" href="/">1</a>),
        ~s(<a class="page" href="/?page=2">2</a>),
        ~s(<a class="page" href="/?page=3" rel="prev">3</a>),
        ~s(<span class="current-page">4</span>),
        ~s(<a class="page" href="/?page=5" rel="next">5</a>),
        ~s(<a class="page" href="/?page=6">6</a>),
        ~s(<a class="page" href="/?page=7">7</a>),
        ~s(<a class="page" href="/?page=5" rel="next">›</a>),
        ~s(<a class="page" href="/?page=7">»</a>)
      ] |> to_string
  end

  def render_block(label, pagination) do
    label
    |> render_pagination(pagination, %{}, &image_path(%URI{host: ""}, :index, &1))
    |> Phoenix.HTML.Safe.to_iodata
    |> to_string
  end

  def render(pagination) do
    pagination
    |> render_pagination_links(%{}, &image_path(%URI{host: ""}, :index, &1))
    |> Phoenix.HTML.Safe.to_iodata
    |> to_string
  end
end
