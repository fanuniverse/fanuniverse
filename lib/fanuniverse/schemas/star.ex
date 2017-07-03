defmodule Fanuniverse.Star do
  use Fanuniverse.Schema.Polymorphic, resources: [
    image_id: Fanuniverse.Image,
    comment_id: Fanuniverse.Comment]

  alias Fanuniverse.User
  alias Fanuniverse.Star
  alias Fanuniverse.Repo

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

  def for_uniform_resources_and_user(_, nil), do: nil
  def for_uniform_resources_and_user([], _user), do: nil
  def for_uniform_resources_and_user(resources, %User{id: user_id})
      when is_list(resources) do
    {key, ids} = Enum.reduce(resources, {"", []},
      fn(resource, {_key, ids}) ->
        {key, id} = Star.resource_key_and_id(resource)
        {key, [id | ids]}
      end)

    stars =
      from s in Star,
      select: field(s, ^key),
      where: field(s, ^key) in ^ids,
      where: s.user_id == ^user_id

    {key, Repo.all(stars)}
  end
end
