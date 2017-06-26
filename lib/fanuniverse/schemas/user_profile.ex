defmodule Fanuniverse.UserProfile do
  use Fanuniverse.Schema

  alias Fanuniverse.User

  schema "user_profiles" do
    field :bio, :string
    field :comments_count, :integer

    belongs_to :user, User
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:bio])
  end
end
