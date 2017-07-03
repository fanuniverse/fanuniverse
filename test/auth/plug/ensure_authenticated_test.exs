defmodule Auth.Plug.EnsureAuthenticatedTest do
  use Fanuniverse.Web.ConnCase

  alias Auth.Plug.EnsureAuthenticated
  alias Fanuniverse.User

  test "passes through when user is authenticated" do
    conn =
      build_conn()
      |> assign(:current_user, %User{})
      |> EnsureAuthenticated.call(%{})

    assert conn.status != 302
  end

  test "redirects to the sign up page when user is not authenticated" do
    conn =
      build_conn()
      |> EnsureAuthenticated.call(%{})

    assert redirected_to(conn) == "/sign_up"
  end
end
