defmodule Auth.Plug.LoadAuthenticatedUserTest do
  use Fanuniverse.Web.ConnCase

  import Plug.Test

  alias Auth.Plug.LoadAunthenticatedUser

  test "assigns a user when user_id is present in session" do
    user =
      insert_user(%{name: "Auth", email: "auth@tld", password: "password"})
      # reset virtual fields
      |> Map.put(:password, nil)
      |> Map.put(:password_confirmation, nil)
    conn =
      build_conn()
      |> init_test_session(%{user_id: user.id})
      |> LoadAunthenticatedUser.call(%{})

    assert conn.assigns[:user] == user
  end

  test "assigns nil when user_id is not present in session" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> LoadAunthenticatedUser.call(%{})

    assert conn.assigns[:user] == nil
  end
end
