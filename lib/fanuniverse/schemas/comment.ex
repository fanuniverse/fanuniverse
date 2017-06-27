defmodule Fanuniverse.Comment do
  use Fanuniverse.Schema

  alias Fanuniverse.User
  alias Fanuniverse.UserProfile
  alias Fanuniverse.Image
  alias Fanuniverse.Comment

  @resources [image_id: Image, user_profile_id: UserProfile]

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

  def query_for_resource(resource) do
    from c in Comment, where: ^[resource_key_and_id(resource)]
  end

  for {resource, resource_struct} <- @resources do
    resource_string = Atom.to_string(resource)

    @doc """
    Extracts a tuple of `{resource_key_atom, resource_id}` (e.g. {:image_id, 1})
    from a given map/struct that
    a) has the resource_key as string or an atom (e.g. %{"image_id" => 1})
    b) belongs to the resource_struct type (e.g. %Image{id: 1})
    """
    def resource_key_and_id(%{unquote(resource_string) => id})
      when not is_nil(id), do: {unquote(resource), id}
    def resource_key_and_id(%{unquote(resource) => id})
      when not is_nil(id), do: {unquote(resource), id}
    def resource_key_and_id(%unquote(resource_struct){id: id}),
      do: {unquote(resource), id}
  end
end
