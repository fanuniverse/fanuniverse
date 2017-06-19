defmodule Fanuniverse.UserSessionControllerTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  describe "/sign_in" do
    test "creates a new session when provided with valid credentials" do
      user = test_user()
      conn = sign_in user

      assert redirected_to(conn) == "/"
      assert get_session(conn, "user_id") == user.id
    end

    test "displays an error when authentication fails" do
      user = test_user()
      conn = sign_in user, password: "not#{user.password}"

      assert html_response(conn, 200) =~ "Invalid username and/or password"
      assert get_session(conn, "user_id") == nil
    end
  end

  describe "/sign_out" do
    test "deletes the session when requested by an authenticated user" do
      user = test_user()
      conn = sign_in(user) |> delete("/sign_out")

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "You have signed out successfully."
      assert get_session(conn, "user_id") == nil
    end

    test "redirects to the sign up page when user is not authenticated" do
      conn = delete build_conn(), "/sign_out"

      assert redirected_to(conn) == "/sign_up"
    end
  end

  defp sign_in(user, override_with \\ []) do
    post build_conn(), "/sign_in", session: %{
      email: override_with[:email] || user.email,
      password: override_with[:password] || user.password}
  end
end
