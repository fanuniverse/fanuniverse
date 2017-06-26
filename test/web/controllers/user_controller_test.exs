defmodule Fanuniverse.UserControllerTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  describe "/sign_up" do
    test "creates a user and logs them in" do
      session =
        build_conn()
        |> post("/sign_up", %{user: %{name: "agate", email: "agate@homeworld",
            password: "password", password_confirmation: "password"}})

      assert redirected_to(session) == "/"
      assert get_flash(session, :info) == "You have signed up successfully."

      user =
        Repo.get!(User, get_session(session, "user_id"))
        |> Repo.preload(:user_profile)

      assert user.name == "agate"
      assert user.user_profile.bio == ""
    end

    test "displays an error message if validation fails" do
      session =
        build_conn()
        |> post("/sign_up", %{user: %{email: "agate@homeworld",
            password: "password", password_confirmation: "password"}})

      assert html_response(session, 200) =~ ~r/Name can.+t be blank/
      assert get_session(session, "user_id") == nil
    end

    test "redirects to the home page if user is logged in" do
      session =
        build_conn()
        |> Plug.Test.init_test_session(%{})
        |> Auth.UserSession.init(test_user())

      assert (session |> get("/sign_up") |> redirected_to) == "/"
      assert (session |> post("/sign_up", %{user: %{}}) |> redirected_to) == "/"
    end
  end
end
