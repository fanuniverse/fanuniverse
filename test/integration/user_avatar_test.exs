defmodule Fanuniverse.UserAvatarIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  import Ecto.Query

  @fixture "test/fixtures/avatar.jpg"
  @fixture_ext "jpg"
  @tmp_dir "/tmp/plug-1497"
  @tmp_path "/tmp/plug-1497/avatar-upload"
  @plug_upload %Plug.Upload{
    content_type: "image/jpeg", filename: "avatar.jpg", path: @tmp_path}

  setup do
    File.mkdir(@tmp_dir)
    :ok = File.cp(@fixture, @tmp_path)

    user = test_user()

    on_exit fn ->
      File.rm(@tmp_path)
      File.rm(avatar_path(user.name))
    end

    {:ok, %{session: test_user_session(), user: user}}
  end

  test "user can upload an avatar and remove it",
      %{session: session, user: %User{name: username}} do
    session =
      session |> patch("/profile", %{"user" => %{"avatar" => @plug_upload}})
    assert "/profiles/" <> ^username = redirected_to(session)

    assert File.exists?(avatar_path(username))

    user = Repo.one(from(u in User, where: u.name == ^username))
    assert user.avatar_file_ext == @fixture_ext

    session =
      session |> patch("/profile", %{"user" => %{"remove_avatar" => "true"}})
    assert "/profiles/" <> ^username = redirected_to(session)

    refute File.exists?(avatar_path(username))

    user = Repo.one(from(u in User, where: u.name == ^username))
    assert user.avatar_file_ext == nil
  end

  defp avatar_path(username),
    do: "priv/avatars/#{username}.#{@fixture_ext}"
end
