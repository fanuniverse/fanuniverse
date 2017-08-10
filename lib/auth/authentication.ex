defmodule Auth.Authentication do
  @moduledoc """
  Controller functions for authenticating users.
  """

  import Fanuniverse.Repo, only: [one: 1]
  import Ecto.Query

  alias Fanuniverse.User
  alias Comeonin.Bcrypt

  @doc """
  Returns `{:ok, %User{}}` if user is authenticated, `:error` otherwise.
  """
  def authenticate(email, password) do
    User
    |> where(email: ^email)
    |> one()
    |> do_authenticate(password)
  end

  defp do_authenticate(%User{password_hash: password_hash} = user, password) do
    if Bcrypt.checkpw(password, password_hash) do
      {:ok, user}
    else
      :error
    end
  end
  defp do_authenticate(_, _) do
    Bcrypt.dummy_checkpw()
    :error
  end
end
