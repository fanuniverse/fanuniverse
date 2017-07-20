defmodule Fanuniverse.Web.StaticPageView do
  use Fanuniverse.Web, :view

  def render("title", %{action_name: :privacy}),
    do: "Privacy Policy"
end
