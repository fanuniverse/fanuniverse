defmodule Auth.Plug.LoadAuthenticatedUserTest do
  use Fanuniverse.Web.ConnCase

  import Plug.Test

  alias Auth.Plug.LoadAunthenticatedUser
  alias Fanuniverse.User

  test "assigns a user when user_id is present in session" do
    user =
      %{name: "Auth",
        email: "auth@tld",
        password: "password"}
      |> insert_user()
      |> (&Repo.get!(User, &1.id)).()

    conn =
      build_conn()
      |> init_test_session(%{user_id: user.id})
      |> LoadAunthenticatedUser.call(%{})

    assert conn.assigns[:current_user] == user

    assert %Ecto.Association.NotLoaded{} =
      conn.assigns[:current_user].user_profile
  end

  test "assigns nil when user_id is not present in session" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> LoadAunthenticatedUser.call(%{})

    assert conn.assigns[:current_user] == nil
  end
end
