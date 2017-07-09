defmodule Fanuniverse.Image do
  use Fanuniverse.Schema

  alias Fanuniverse.Image
  alias Fanuniverse.Image.Tags
  alias Fanuniverse.User

  schema "images" do
    field :tags, Tags
    field :source, :string

    field :stars_count, :integer
    field :comments_count, :integer

    field :width, :integer
    field :height, :integer
    field :phash, :string
    field :ext, :string

    field :processed, :boolean, default: false

    field :merged_into_id, :integer

    timestamps()
  end

  # Public interface

  def update(%Image{} = image, %User{} = user, params) do
    {new_tags, added_tags, removed_tags} =
      Tags.update(image.tags, params["tags"], params["tag_cache"])
    params =
      Map.put(params, "tags", new_tags)
    update =
      image |> changeset(params) |> PaperTrail.update(user: user)

    case update do
      {:ok, %{model: image}} ->
        # TODO: reindex the Elasticsearch document
        {:ok, image}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:source, :tags])
    |> validate_required([:source, :tags])
    |> Tags.validate
  end

  def processed_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:width, :height, :phash, :ext])
    |> validate_required([:width, :height, :phash, :ext])
    |> put_change(:processed, true)
  end
end
