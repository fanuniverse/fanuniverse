defmodule Fanuniverse.Comment do
  use Fanuniverse.Schema.Polymorphic, resources: [
    image_id: Fanuniverse.Image,
    user_profile_id: Fanuniverse.UserProfile]

  alias Fanuniverse.User
  alias Fanuniverse.Comment

  schema "comments" do
    field :body, :string
    field :stars_count, :integer
    belongs_to :user, User

    field :image_id, :integer
    field :user_profile_id, :integer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :image_id, :user_profile_id])
    |> cast_assoc(:user, required: true)
    |> validate_required([:body])
    |> foreign_key_constraint(:image_id)
    |> foreign_key_constraint(:user_profile_id)
    |> check_constraint(:id, name: :belongs_to_integrity,
        message: "A comment must belong to a single resource.")
  end
end
