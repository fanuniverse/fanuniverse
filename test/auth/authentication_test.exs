defmodule Auth.AuthenticationTest do
  use Fanuniverse.DataCase

  import Auth.Authentication, only: [authenticate: 2]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Fanuniverse.User

  setup do
    {:ok, user} =
      Repo.insert(%User{
        email: "mail@example.com",
        password_hash: hashpwsalt("password")})

    [user: user]
  end

  test "authenticates a user", context do
    result = authenticate("mail@example.com", "password")
    assert result == {:ok, context[:user]}
  end

  test "returns an error when the password is invalid", _ do
    result = authenticate("mail@example.com", "Password")
    assert result == :error
  end
end
