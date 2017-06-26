defmodule Fanuniverse.User do
  use Fanuniverse.Schema

  alias Comeonin.Bcrypt
  alias Fanuniverse.UserProfile

  # Catches basic mistakes such as having multiple @s or whitespace.
  # Source: https://stackoverflow.com/a/742588/1726690
  @valid_email ~r/\A[^@\s]+@[^@\s]+\z/
  @non_unique_email_message "has already been used"

  @valid_name ~r/\A(?!-)(?!.+--)[a-zA-Z0-9-]+(?<!-)\z/
  @invalid_name_message "may contain alphanumeric characters or hyphens only, \
and cannot begin or end with a hyphen."

  @min_password_length 8

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_one :user_profile, UserProfile

    timestamps()
  end

  def registration_changeset(struct, params \\ %{}) do
   struct
   |> cast(params, [:name, :email, :password, :password_confirmation])
   |> validate_required([:name, :email, :password, :password_confirmation])
   |> validate_format(:name, @valid_name, message: @invalid_name_message)
   |> validate_format(:email, @valid_email)
   |> validate_length(:password, min: @min_password_length)
   |> validate_confirmation(:password)
   |> hash_password()
   |> unique_constraint(:email, message: @non_unique_email_message)
   |> unique_constraint(:name, name: :users_lowercase_name_index)
 end

 defp hash_password(%{valid?: true} = changeset) do
   password_hash = changeset |> get_field(:password) |> Bcrypt.hashpwsalt()
   put_change(changeset, :password_hash, password_hash)
 end
 defp hash_password(invalid_changeset), do: invalid_changeset
end
