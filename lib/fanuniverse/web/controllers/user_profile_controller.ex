defmodule Fanuniverse.Web.UserProfileController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.User
  alias Fanuniverse.UserProfile
  alias Fanuniverse.UserAvatarService, as: UserAvatar

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

    render conn, "edit.html", active_tab: :profile,
      profile_changeset: UserProfile.changeset(profile),
      avatar_changeset: User.changeset(profile.user),
      user_changeset: User.changeset(profile.user)
  end

  def update(conn, %{"user_profile" => profile_params}) do
    profile = profile_for_current_user(conn)
    changeset = UserProfile.changeset(profile, profile_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        redirect_to_profile conn, profile
      {:error, error_changeset} ->
        render conn, "edit.html", active_tab: :profile,
          profile_changeset: error_changeset,
          avatar_changeset: User.changeset(profile.user),
          user_changeset: User.changeset(profile.user)
    end
  end
  def update(conn, %{"user" => %{"avatar" => upload}}),
    do: update_avatar(conn, &UserAvatar.add(&1, upload))
  def update(conn, %{"user" => %{"remove_avatar" => "true"}}),
    do: update_avatar(conn, &UserAvatar.remove(&1))

  def update_avatar(conn, update_fun) when is_function(update_fun, 1) do
    profile = profile_for_current_user(conn)

    case update_fun.(profile.user) do
      :ok ->
        redirect_to_profile conn, profile
      {:error, error_changeset} ->
        render conn, "edit.html", active_tab: :avatar,
          profile_changeset: UserProfile.changeset(profile),
          avatar_changeset: error_changeset,
          user_changeset: User.changeset(profile.user)
    end
  end

  defp redirect_to_profile(conn, profile),
    do: redirect conn, to: user_profile_path(conn, :show, profile.user.name)

  defp profile_for_current_user(conn) do
    profile =
      UserProfile
      |> where(user_id: ^user(conn).id)
      |> Repo.one()

    %{profile | user: user(conn)}
  end
end
