defmodule Fanuniverse.Comment do
  use Fanuniverse.Schema

  alias Fanuniverse.User
  alias Fanuniverse.UserProfile
  alias Fanuniverse.Image
  alias Fanuniverse.Comment

  @resource_keys [:image_id, :user_profile_id]

  schema "comments" do
    field :body, :string
    field :stars_count, :integer
    belongs_to :user, User

    # Each comment only belongs to a single resource;
    # this is enforced by a database constraint.
    belongs_to :image, Image
    belongs_to :user_profile, UserProfile

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

  for resource <- @resource_keys do
    resource_string = Atom.to_string(resource)

    def single_resource_query(%{unquote(resource_string) => res_id}),
      do: from c in Comment,
          where: [{unquote(resource), ^res_id}]
    def single_resource_query(%Comment{unquote(resource) => res_id})
      when not is_nil(res_id),
      do: from c in Comment,
          where: [{unquote(resource), ^res_id}]
  end
end
