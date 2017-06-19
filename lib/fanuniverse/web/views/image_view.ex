defmodule Fanuniverse.Web.ImageView do
  use Fanuniverse.Web, :view

  def render("title", %{action_name: :new}), do: "Suggest an image"
  def render("title", %{action_name: :show, image: image}) do
    "#{image.id} ∙ #{image.tags}"
  end

  def short_source(@image) do
    URI.parse(@image.source).host
  end
end
