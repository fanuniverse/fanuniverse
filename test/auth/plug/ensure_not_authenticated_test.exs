defmodule Auth.Plug.EnsureNotAuthenticatedTest do
  use Fanuniverse.Web.ConnCase

  alias Auth.Plug.EnsureNotAuthenticated
  alias Fanuniverse.User

  test "passes through when user is not authenticated" do
    conn =
      build_conn()
      |> EnsureNotAuthenticated.call(%{})

    assert conn.status != 302
  end

  test "redirects to the home page when user is authenticated" do
    conn =
      build_conn()
      |> assign(:user, %User{})
      |> EnsureNotAuthenticated.call(%{})

    assert redirected_to(conn) == "/"
  end
end
