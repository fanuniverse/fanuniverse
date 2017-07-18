defmodule Fanuniverse.Web.Admin.ImageView do
  use Fanuniverse.Web, :view

  import Fanuniverse.Web.ImageView, only: [version_url: 2]

  def render("layout", %{action_name: :merge}), do: :medium
end
