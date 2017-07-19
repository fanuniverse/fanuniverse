defmodule Auth.UserSession do
  @moduledoc """
  Convenience functions for manipulating user session state
  (signed in/signed out).

  A single variable, `user_id`, is kept in the session. This, of
  course, assumes that sessions are stored on the server side.

  Related: `Auth.Plug.EnsureAuthenticated` and
  `Auth.Plug.LoadAunthenticatedUser`.
  """

  alias Fanuniverse.User

  import Plug.Conn

  def init(conn, %User{id: user_id}) do
    conn
    |> configure_session(renew: true)
    |> put_session("user_id", user_id)
  end

  def delete(conn) do
    conn
    |> configure_session(renew: true)
    |> delete_session("user_id")
  end
end
