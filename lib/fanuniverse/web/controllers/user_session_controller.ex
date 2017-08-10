defmodule Fanuniverse.Web.UserSessionController do
  use Fanuniverse.Web, :controller

  import Auth.Authentication, only: [authenticate: 2]

  plug EnsureNotAuthenticated when action in [:new, :create]
  plug EnsureAuthenticated when action in [:delete]

  def new(conn, _params), do: render(conn, "new.html")

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case authenticate(email, password) do
      {:ok, user} ->
        conn
        |> Auth.UserSession.init(user)
        |> redirect(to: "/")
      :error ->
        conn
        |> put_flash(:error, "Invalid username and/or password.")
        |> render("new.html")
     end
  end

  def delete(conn, _params) do
    conn
    |> Auth.UserSession.delete()
    |> put_flash(:info, "You have signed out successfully.")
    |> redirect(to: "/")
  end
end
