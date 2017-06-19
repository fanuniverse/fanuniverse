defmodule Fanuniverse.UserTest do
  use Fanuniverse.DataCase

  alias Fanuniverse.User

  describe "registration changeset" do
    test "validates password confirmation" do
      changeset = User.registration_changeset(%User{}, test_changeset(
        password: "password", password_confirmation: "Password"))
      refute changeset.valid?
    end

    test "hashes the password when the changeset is valid" do
      changeset = User.registration_changeset(%User{}, test_changeset())
      assert changeset.valid?
      assert changeset |> get_field(:password_hash) |> String.starts_with?("$")
    end

    test "fails if name is already taken (case-insensitive)" do
      insert_user test_changeset(name: "Blue", email: "blue@tld")

      second_user = User.registration_changeset(%User{}, test_changeset(
        name: "blue", email: "anotherblue@tld"))

      assert {:error, changeset} = Repo.insert(second_user)
      assert {:name, {"has already been taken", []}} in changeset.errors
    end

    test "fails if email is already taken" do
      insert_user test_changeset(name: "Yellow", email: "yellow@tld")

      second_user = User.registration_changeset(%User{}, test_changeset(
        name: "yelloww", email: "yellow@tld"))

      assert {:error, changeset} = Repo.insert(second_user)
      assert {:email, {"has already been used", []}} in changeset.errors
    end
  end

  defp test_changeset(overridden_fields \\ []) do
    %{name: "UserTestChanget", email: "usertest@example.com",
      password: "password", password_confirmation: "password"}
    |> Map.merge(Enum.into(overridden_fields, %{}))
  end
end
