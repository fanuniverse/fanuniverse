defmodule Fanuniverse.Web.ImageView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.Image
  alias Fanuniverse.Repo

  import Ecto.Query

  @image_sort_keys ~w(newest oldest popular undiscovered most_discussed)
  @image_sorts [
    newest:         {"Newest first",   :created_at, :desc},
    oldest:         {"Oldest first",   :created_at, :asc},
    popular:        {"Popular",        :stars,      :desc},
    undiscovered:   {"Undiscovered",   :stars,      :asc},
    most_discussed: {"Most discussed", :comments,   :desc}
  ]

  def render("title", %{action_name: :new}),
    do: "Suggest an image"
  def render("title", %{action_name: :show, image: image}),
    do: "#{image.id} ∙ #{image.tags}"
  def render("title", %{action_name: :edit, image: image}),
    do: "#{image.id} ∙ Updating image metadata"
  def render("title", %{action_name: :history, image: image}),
    do: "#{image.id} ∙ Image history"

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


  def short_source(image) do
    URI.parse(image.source).host
  end

  def has_paper_trail_versions?(%Image{id: id}) do
    Repo.one(
      from v in PaperTrail.Version,
      select: fragment("true"),
      where: [item_type: "Image", item_id: ^id, event: "update"],
      limit: 1)
  end

  def paper_trail_diffs(conn, %Image{id: id}) do
    [initial | updates] =
      Repo.all(
        from v in PaperTrail.Version,
        where: [item_type: "Image", item_id: ^id],
        order_by: [asc: :inserted_at],
        preload: :user)

    initial_state =
      (fn(%{item_changes: %{"tags" => %{"list" => tags},
                            "source" => source}}) ->
        %{tags: tags, source: source}
      end).(initial)

    do_paper_trail_diffs(conn, updates, initial_state, [])
  end

  defp do_paper_trail_diffs(_, [], _, diffs), do: diffs
  defp do_paper_trail_diffs(conn, [current | rest], state, diffs) do
    {tag_diff, state} =
      if current.item_changes |> Map.has_key?("tags") do
        new = current.item_changes["tags"]["list"]
        added = new -- state[:tags]
        removed = state[:tags] -- new

        tag_diffs = [
          tag_diff(conn, added, "Added"),
          tag_diff(conn, removed, "Removed")
        ]

        {tag_diffs, %{state | tags: new}}
      else
        {"", state}
      end
    {source_diff, state} =
      if current.item_changes |> Map.has_key?("source") do
        new = current.item_changes["source"]
        old = state[:source]

        {source_diff(old, new), %{state | source: new}}
      else
        {"", state}
      end

    diff =
      content_tag(:div, class: "block history") do
        [
          content_tag(:div, class: "history__user") do
            current.user.name
          end,
          tag_diff,
          source_diff,
          content_tag(:div, class: "history__time") do
            time_tag(current.inserted_at)
          end
        ]
      end

    do_paper_trail_diffs(conn, rest, state, [diff, diffs])
  end

  def tag_diff(_, [], _), do: ""
  def tag_diff(conn, tags, action_label) do
    [
      content_tag(:div, class: "history__label") do
        [
          "#{action_label} ",
          (if length(tags) == 1,
            do: "1 tag",
            else: "#{length(tags)} tags")
        ]
      end,
      content_tag(:section) do
        for tag <- tags do
          link tag, to: image_path(conn, :index, q: tag), class: "tag"
        end
      end
    ]
  end

  def source_diff(old, new) do
    content_tag(:div, class: "history__label") do
      content_tag(:p) do
        [
          "Changed image source from ",
          content_tag(:em, old),
          " to ",
          content_tag(:em, new)
        ]
      end
    end
  end
end
