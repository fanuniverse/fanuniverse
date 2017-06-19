defmodule Fanuniverse.UserAuthenticationActionTest do
  use Fanuniverse.DataCase

  alias Fanuniverse.User
  alias Fanuniverse.UserAuthenticationAction, as: Authentication

  setup do
    password_hash =
      Comeonin.Bcrypt.hashpwsalt("password")
    {:ok, user} =
      Repo.insert(%User{email: "mail@example.com", password_hash: password_hash})

    [user: user]
  end

  test "authenticates a user", context do
    result = Authentication.perform("mail@example.com", "password")
    assert result == {:ok, context[:user]}
  end

  test "returns an error when the password is invalid", _ do
    result = Authentication.perform("mail@example.com", "Password")
    assert result == :error
  end
end
