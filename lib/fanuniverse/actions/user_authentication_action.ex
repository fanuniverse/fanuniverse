defmodule Fanuniverse.UserAuthenticationAction do
  alias Fanuniverse.User
  alias Comeonin.Bcrypt

  import Fanuniverse.Repo, only: [one: 1]
  import Ecto.Query

  def perform(email, password) do
    User
    |> where(email: ^email)
    |> one
    |> authenticate(password)
  end

  defp authenticate(%User{password_hash: password_hash} = user, password) do
    if Bcrypt.checkpw(password, password_hash) do
      {:ok, user}
    else
      :error
    end
  end
  defp authenticate(_, _) do
    Bcrypt.dummy_checkpw
    :error
  end
end
