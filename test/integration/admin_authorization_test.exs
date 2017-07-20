defmodule Fanuniverse.AdminAuthorizationIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  setup do
    user =
      insert_user(%{name: "a-pearl",
        email: "pearl@homeworld", password: "password"})
    admin =
      insert_user(%{name: "her-diamond",
        email: "boxestastelikemush@homeworld", password: "password"})
      |> Ecto.Changeset.change(role: "administrator")
      |> Repo.update!()

    {:ok, %{
      guest: build_conn(),
      user: signed_in_session(user),
      admin: signed_in_session(admin)
    }}
  end

  test "admin routes", context do
    assert_admin_only "/admin/dashboard", context
    assert_admin_only "/admin/images/merge", context, %{
      "source" => insert(:image).id, "target" => insert(:image).id}
    assert_admin_only "/admin/reports", context
  end

  def assert_admin_only(path, %{guest: guest, user: user, admin: admin}, params \\ %{}) do
    assert guest |> get(path, params) |> redirected_to(302) == "/sign_up"
    assert user  |> get(path, params) |> redirected_to(302) == "/"
    assert admin |> get(path, params) |> response(200)
  end
end
