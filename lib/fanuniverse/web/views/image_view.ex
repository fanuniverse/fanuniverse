defmodule Fanuniverse.Web.ImageView do
  use Fanuniverse.Web, :view

  @image_sort_keys ~w(newest oldest popular undiscovered most_discussed)
  @image_sorts [
    newest:         {"Newest first",   "created_at", :desc},
    oldest:         {"Oldest first",   "created_at", :asc},
    popular:        {"Popular",        "stars",      :desc},
    undiscovered:   {"Undiscovered",   "stars",      :asc},
    most_discussed: {"Most discussed", "comments",   :desc}
  ]

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

  def render("title", %{action_name: :new}), do: "Suggest an image"
  def render("title", %{action_name: :show, image: image}) do
    "#{image.id} ∙ #{image.tags}"
  end

  def short_source(image) do
    URI.parse(image.source).host
  end
end
