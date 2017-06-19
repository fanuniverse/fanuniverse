defmodule Fanuniverse.Web.UserController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.User

  plug EnsureNotAuthenticated when action in [:new, :create]

  def new(conn, _params) do
    changeset = User.registration_changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Auth.UserSession.init(user)
        |> put_flash(:info, "You have signed up successfully.")
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end
