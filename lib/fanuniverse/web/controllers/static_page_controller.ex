defmodule Fanuniverse.Web.StaticPageController do
  use Fanuniverse.Web, :controller

  require Fanuniverse.Web.Router.StaticPages, as: StaticPages

  for page <- StaticPages.list() do
    page_template = "#{page}.html"

    def unquote(page)(conn, _), do: render(conn, unquote(page_template))
  end
end
