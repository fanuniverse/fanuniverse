defmodule Fanuniverse.Web.LayoutView do
  use Fanuniverse.Web, :view

  def page_title(conn, assigns) do
    main_title = "Fan Universe"

    custom_title = render_existing view_module(conn), "title",
      Map.put(assigns, :action_name, action_name(conn))

    if custom_title do
      custom_title <> " ∙ " <> main_title
    else
      main_title
    end
  end
end
