defmodule Fanuniverse.Web.UserProfileController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.User
  alias Fanuniverse.UserProfile

  plug EnsureAuthenticated when action in [:edit, :update]

  def show(conn, %{"name" => name}) do
    user =
      User
      |> where(name: ^name)
      |> preload(:user_profile)
      |> Repo.one

    render conn, "show.html", user: user
  end

  def edit(conn, _params) do
    profile = profile_for_current_user(conn)

    render conn, "edit.html",
      profile_changeset: UserProfile.changeset(profile),
      user_changeset: User.changeset(profile.user)
  end

  def update(conn, %{"user_profile" => profile_params}) do
    profile = profile_for_current_user(conn)
    changeset = UserProfile.changeset(profile, profile_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        redirect conn,
          to: user_profile_path(conn, :show, profile.user.name)
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end

  defp profile_for_current_user(conn) do
    profile =
      UserProfile
      |> where(user_id: ^user(conn).id)
      |> Repo.one()

    %{profile | user: user(conn)}
  end
end
