defmodule Fanuniverse.Web.StaticPageView do
  use Fanuniverse.Web, :view

  def render("title", %{action_name: :intro}), do: "Intro"
  def render("title", %{action_name: :privacy}), do: "Privacy Policy"

  def render("layout", %{action_name: :intro}), do: :custom
end
