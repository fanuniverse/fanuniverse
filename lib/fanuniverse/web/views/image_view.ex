defmodule Fanuniverse.Web.ImageView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.Image
  alias Fanuniverse.Repo

  import Ecto.Query

  @image_sort_keys ~w(newest oldest popular undiscovered most_discussed)
  @image_sorts [
    newest:         {"Newest first",   "created_at", :desc},
    oldest:         {"Oldest first",   "created_at", :asc},
    popular:        {"Popular",        "stars",      :desc},
    undiscovered:   {"Undiscovered",   "stars",      :asc},
    most_discussed: {"Most discussed", "comments",   :desc}
  ]

  def render("title", %{action_name: :new}),
    do: "Suggest an image"
  def render("title", %{action_name: :show, image: image}),
    do: "#{image.id} ∙ #{image.tags}"
  def render("title", %{action_name: :edit, image: image}),
    do: "#{image.id} ∙ Updating image metadata"

  def render("layout", %{action_name: :index}), do: :wide
  def render("layout", %{action_name: :show}), do: :custom

  def image_sort_key(%{"sort" => sort}) when sort in @image_sort_keys,
    do: String.to_existing_atom(sort)
  def image_sort_key(_default),
    do: :newest

  def image_sort_field_direction(params) do
    {_, field, direction} = @image_sorts[image_sort_key(params)]
    {field, direction}
  end

  def image_sort_options(conn) do
    current = image_sort_key(conn.params)
    {@image_sorts[current], Keyword.delete(@image_sorts, current)}
  end

  def animated?(%Image{ext: "gif"}), do: true
  def animated?(_), do: false

  def version_url(%Image{ext: ext} = image, version) do
    version_url(image, version, ext)
  end
  def version_url(%Image{id: id}, version, ext) do
    root = Application.get_env(:fanuniverse, :image_url_root)
    "#{root}/#{id}/#{version}.#{ext}"
  end

  def has_paper_trail_versions?(%Image{id: id}) do
    Repo.one(
      from v in PaperTrail.Version,
      where: v.item_type == "Image",
      where: v.item_id == ^id,
      where: v.event == "update",
      limit: 1,
    select: fragment("true"))
  end

  def short_source(image) do
    URI.parse(image.source).host
  end
end
