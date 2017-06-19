defmodule Fanuniverse.Image do
  use Fanuniverse.Schema

  alias Fanuniverse.Image.Tags

  schema "images" do
    field :tags, Tags
    field :source, :string

    field :stars_count, :integer
    field :comments_count, :integer

    field :width, :integer
    field :height, :integer
    field :phash, :string

    field :processed, :boolean, default: false

    field :merged_into_id, :integer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:source, :tags])
    |> validate_required([:source, :tags])
    |> Tags.validate
  end

  def processed_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:width, :height, :phash])
    |> validate_required([:width, :height, :phash])
    |> put_change(:processed, true)
  end
end
