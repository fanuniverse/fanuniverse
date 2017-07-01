defmodule Pagination.HTML do
  import Phoenix.HTML.Link
  import Phoenix.HTML.Tag, only: [content_tag: 3]

  def render_pagination(item_label, %Pagination{} = pagination, params, path_with_params)
      when is_binary(item_label) and is_map(params) and is_function(path_with_params, 1) do
    content_tag :div, class: "block flex" do
      [
        content_tag :div, class: "flex__main" do
          content_tag :nav, class: "pagination" do
            render_pagination_links(pagination, params, path_with_params)
          end
        end,

        content_tag :div, class: "flex__right" do
          %{page: page, per_page: per_page, total_count: total} = pagination

          from = 1 + ((page - 1) * per_page)
          to = min(from + per_page - 1, total)

          "Showing #{item_label} #{from}-#{to} out of #{total}"
        end
      ]
    end
  end

  def render_pagination_links(%Pagination{} = pagination, params, path_with_params)
      when is_function(path_with_params, 1) do
    initial_state = %{
      pagination: pagination,
      params: params,
      path_fun: path_with_params,
      rendered: []
    }

    %{rendered: rendered} =
      initial_state
      |> first_page_arrow()
      |> previous_page_arrow()
      |> left_gap()
      |> previous_page_links()
      |> current_page()
      |> next_page_links()
      |> right_gap()
      |> next_page_arrow()
      |> last_page_arrow()

    rendered
  end

  defp first_page_arrow(%{pagination: %{page: 1}} = state), do: state
  defp first_page_arrow(state) do
    content =
      link_to_page(1, "«", state.params, state.path_fun)

    %{state | rendered: [state.rendered, content]}
  end

  defp previous_page_arrow(%{pagination: %{page: 1}} = state), do: state
  defp previous_page_arrow(%{pagination: %{page: page}} = state) do
    content =
      link_to_page(page - 1, "‹", "prev", state.params, state.path_fun)

    %{state | rendered: [state.rendered, content]}
  end

  defp left_gap(%{pagination: %{page: page}} = state) when page < 5, do: state
  defp left_gap(state) do
    content = content_tag(:span, "…", class: "page-gap")

    %{state | rendered: [state.rendered, content]}
  end

  defp previous_page_links(%{pagination: %{page: 1}} = state), do: state
  defp previous_page_links(%{pagination: %{page: 2}} = state) do
    content =
      link_to_page(1, "1", "prev", state.params, state.path_fun)

    %{state | rendered: [state.rendered, content]}
  end
  defp previous_page_links(%{pagination: %{page: 4}} = state) do
    content = [
      link_to_page(1, "1", state.params, state.path_fun),
      link_to_page(2, "2", state.params, state.path_fun),
      link_to_page(3, "3", "prev", state.params, state.path_fun)
    ]

    %{state | rendered: [state.rendered, content]}
  end
  defp previous_page_links(%{pagination: %{page: page}} = state) do
    content = [
      link_to_page(page - 2, to_string(page - 2),
        state.params, state.path_fun),
      link_to_page(page - 1, to_string(page - 1), "prev",
        state.params, state.path_fun)
    ]

    %{state | rendered: [state.rendered, content]}
  end

  defp current_page(%{pagination: %{page: page}} = state) do
    content =
      content_tag(:span, to_string(page), class: "current-page")

    %{state | rendered: [state.rendered, content]}
  end

  defp next_page_links(%{pagination: %{page: last, total_pages: last}} = state),
    do: state
  defp next_page_links(%{pagination: %{page: page, total_pages: last}} = state)
      when (page + 1) == last do
    content =
      link_to_page(page + 1, to_string(page + 1), "next",
        state.params, state.path_fun)

    %{state | rendered: [state.rendered, content]}
  end
  defp next_page_links(%{pagination: %{page: page, total_pages: last}} = state)
      when (page + 3) == last do
    content = [
      link_to_page(page + 1, to_string(page + 1), "next",
        state.params, state.path_fun),
      link_to_page(page + 2, to_string(page + 2),
        state.params, state.path_fun),
      link_to_page(page + 3, to_string(page + 3),
        state.params, state.path_fun)
    ]

    %{state | rendered: [state.rendered, content]}
  end
  defp next_page_links(%{pagination: %{page: page}} = state) do
    content = [
      link_to_page(page + 1, to_string(page + 1), "next",
        state.params, state.path_fun),
      link_to_page(page + 2, to_string(page + 2),
        state.params, state.path_fun),
    ]

    %{state | rendered: [state.rendered, content]}
  end

  defp right_gap(%{pagination: %{page: page, total_pages: last}} = state)
      when (page + 3) >= last, do: state
  defp right_gap(state) do
    content = content_tag(:span, "…", class: "page-gap")

    %{state | rendered: [state.rendered, content]}
  end

  defp next_page_arrow(%{pagination: %{page: last, total_pages: last}} = state),
    do: state
  defp next_page_arrow(%{pagination: %{page: page}} = state) do
    content =
      link_to_page(page + 1, "›", "next", state.params, state.path_fun)

    %{state | rendered: [state.rendered, content]}
  end

  defp last_page_arrow(%{pagination: %{page: last, total_pages: last}} = state),
    do: state
  defp last_page_arrow(%{pagination: %{total_pages: last}} = state) do
    content =
      link_to_page(last, "»", state.params, state.path_fun)

    %{state | rendered: [state.rendered, content]}
  end

  # Internal helpers

  defp link_to_page(page, text, rel \\ nil, params, path_fun) do
    path =
      if page == 1,
        do: params |> Map.delete("page") |> path_fun.(),
        else: params |> Map.put("page", page) |> path_fun.()

    link(text, to: path, class: "page", rel: rel)
  end
end
