defmodule Fanuniverse.Image do
  use Fanuniverse.Schema

  alias Fanuniverse.Image
  alias Fanuniverse.Image.Tags
  alias Fanuniverse.ImageIndex
  alias Fanuniverse.ImageUploader
  alias Fanuniverse.User

  schema "images" do
    field :tags, Tags
    field :source, :string

    field :stars_count, :integer
    field :comments_count, :integer

    belongs_to :suggested_by, User

    field :width, :integer
    field :height, :integer
    field :phash, :string
    field :ext, :string

    field :processed, :boolean, default: false

    field :merged_into_id, :integer

    timestamps()
  end

  # Public interface

  def insert(params, %User{} = user) do
    ImageUploader.upload(params, fn ->
      status =
        %Image{suggested_by: user}
        |> changeset(params)
        |> PaperTrail.insert(user: user)

      case status do
        {:ok, %{model: image}} ->
          Job.perform fn ->
            Dispatcher.Sapphire.update_tags(image.tags.list, [])
            Elasticfusion.Document.index(image, ImageIndex)
          end
          {:ok, image}
        {:error, changeset} ->
          {:error, changeset}
      end
    end)
  end

  def update(params, %Image{} = image, %User{} = user) do
    {new_tags, added_tags, removed_tags} =
      Tags.update(image.tags,
        params["tags"], params["tag_cache"])
    params =
      Map.put(params, "tags", new_tags)
    status =
      image
      |> changeset(params)
      |> PaperTrail.update(user: user)

    case status do
      {:ok, %{model: image}} ->
        Job.perform fn ->
          Dispatcher.Sapphire.update_tags(added_tags, removed_tags)
          Elasticfusion.Document.index(image, ImageIndex)
        end
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
