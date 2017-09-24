defmodule Fanuniverse.Image do
  use Fanuniverse.Schema

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.Image.Tags
  alias Fanuniverse.ImageUploader
  alias Fanuniverse.User
  alias Fanuniverse.Workers.ImageIndexUpdate
  alias Fanuniverse.Workers.ImageDuplicateDetection

  schema "images" do
    field :tags, Tags
    field :source, :string

    field :stars_count, :integer
    field :comments_count, :integer

    belongs_to :suggested_by, User

    field :width, :integer
    field :height, :integer
    field :hash, :string
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
        {:ok, %{model: %{id: id, tags: tags} = image}} ->
          Job.run(ImageIndexUpdate, id: id, added_tags: tags.list)
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
      {:ok, %{model: %{id: id} = image}} ->
        Job.run(ImageIndexUpdate, id: id,
          added_tags: added_tags, removed_tags: removed_tags)

        {:ok, image}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_after_processing(id, params) do
    status =
      with %Image{} = image <- Repo.get(Image, id),
           changeset        <- processed_changeset(image, params),
        do: Repo.update(changeset)

    case status do
      {:ok, image} ->
        Job.run(ImageIndexUpdate, id: id)
        Job.run(ImageDuplicateDetection, id: id)
        {:ok, image}
      nil ->
        {:error, :not_found}
      error ->
        error
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
    |> cast(params, [:width, :height, :hash, :ext])
    |> validate_required([:width, :height, :hash, :ext])
    |> put_change(:processed, true)
  end
end
