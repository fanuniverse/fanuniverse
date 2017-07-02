defmodule Fanuniverse.Star do
  use Fanuniverse.Schema.Polymorphic, resources: [
    image_id: Fanuniverse.Image,
    comment_id: Fanuniverse.Comment]

  alias Fanuniverse.User

  schema "stars" do
    belongs_to :user, User

    field :image_id, :integer
    field :comment_id, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:image_id, :comment_id])
    |> cast_assoc(:user, required: true)
    |> foreign_key_constraint(:image_id)
    |> foreign_key_constraint(:comment_id)
    |> check_constraint(:id, name: :belongs_to_integrity,
        message: "A star must belong to a single resource.")
  end
end
