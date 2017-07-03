defmodule Auth.Plug.LoadAunthenticatedUser do
  @moduledoc """
  This plug fetches the user stored in the session and inserts it into `assigns`.
  """

  import Plug.Conn

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  def init(opts), do: opts

  def call(conn, _opts) do
    user =
      conn
      |> get_session("user_id")
      |> fetch_user

    assign(conn, :current_user, user)
  end

  defp fetch_user(nil), do: nil
  defp fetch_user(user_id), do: Repo.get(User, user_id)
end
