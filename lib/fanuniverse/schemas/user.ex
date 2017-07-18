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

    field :role, :string
    field :avatar_file_ext, :string

    has_one :user_profile, UserProfile

    timestamps()
  end

  def changeset(struct, params \\ %{}),
    do: cast(struct, params, [:avatar_file_ext])

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password, :password_confirmation])
    |> cast_assoc(:user_profile, required: true)
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_format(:name, @valid_name, message: @invalid_name_message)
    |> process_email_and_password()
    |> unique_constraint(:name, name: :users_lowercase_name_index)
  end

  def account_update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_current_password(params["current_password"])
    |> process_email_and_password()
  end

  defp process_email_and_password(changeset) do
    changeset
    |> validate_format(:email, @valid_email)
    |> validate_length(:password, min: @min_password_length)
    |> validate_confirmation(:password)
    |> hash_password()
    |> unique_constraint(:email, message: @non_unique_email_message)
  end

  defp hash_password(%{valid?: true, changes: %{password: password}} = changeset),
    do: put_change(changeset, :password_hash, Bcrypt.hashpwsalt(password))
  defp hash_password(invalid_changeset),
    do: invalid_changeset

  defp validate_current_password(changeset, password) when is_binary(password) do
    password_hash = get_field(changeset, :password_hash)

    if Bcrypt.checkpw(password, password_hash),
      do: changeset,
      else: validate_current_password(changeset, nil)
  end
  defp validate_current_password(changeset, _invalid_password),
    do: add_error(changeset,
      :current_password, "is required to confirm the changes")
end
