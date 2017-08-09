defmodule Fanuniverse.Web.UserProfileController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.User
  alias Fanuniverse.UserProfile
  alias Fanuniverse.UserAvatarUploader

  plug EnsureAuthenticated when action in [:edit, :update]

  def show(conn, %{"name" => name}) do
    user = Repo.one(
      from u in User,
      where: u.name == ^name,
      preload: :user_profile)

    render conn, "show.html", user: user
  end

  def edit(conn, _params) do
    render_edit conn, :profile,
      (conn |> profile_for_current_user() |> tab_changesets())
  end

  def update(conn, %{"user_profile" => profile_params}) do
    update_profile conn, :profile, fn(profile) ->
      profile
      |> UserProfile.changeset(profile_params)
      |> Repo.update()
    end
  end
  def update(conn, %{"user" => %{"avatar" => upload}}) do
    update_profile conn, :avatar, &UserAvatarUploader.upload(&1.user, upload)
  end
  def update(conn, %{"user" => %{"remove_avatar" => "true"}}) do
    update_profile conn, :avatar, &UserAvatarUploader.remove(&1.user)
  end
  def update(conn, %{"user" => user_params}) do
    update_profile conn, :user, fn(profile) ->
      profile.user
      |> User.account_update_changeset(user_params)
      |> Repo.update()
    end
  end

  defp update_profile(conn, active_tab, profile_update_fun)
      when is_function(profile_update_fun, 1) do
    profile =
      profile_for_current_user(conn)

    case profile_update_fun.(profile) do
      :ok ->
        redirect conn,
          to: user_profile_path(conn, :show, profile.user.name)
      {:ok, _} ->
        redirect conn,
          to: user_profile_path(conn, :show, profile.user.name)
      {:error, error_changeset} ->
        render_edit conn,
          active_tab, tab_changesets(profile, %{active_tab => error_changeset})
    end
  end

  def tab_changesets(profile, initial \\ %{}) do
    initial
    |> Map.put_new(:profile, UserProfile.changeset(profile))
    |> Map.put_new(:avatar, User.changeset(profile.user))
    |> Map.put_new(:user, User.changeset(profile.user))
  end

  def render_edit(conn, active_tab, tab_changesets) do
    render conn, "edit.html", active_tab: active_tab,
      profile_changeset: tab_changesets[:profile],
      avatar_changeset: tab_changesets[:avatar],
      user_changeset: tab_changesets[:user]
  end

  defp profile_for_current_user(conn) do
    profile =
      UserProfile
      |> where(user_id: ^user(conn).id)
      |> Repo.one()

    %{profile | user: user(conn)}
  end
end
