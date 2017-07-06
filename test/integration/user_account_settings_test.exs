defmodule Fanuniverse.UserAccountSettingsIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  setup do
    {:ok, %{session: test_user_session(), user: test_user()}}
  end

  test "changing email", context do
    session = patch(context.session, "/profile",
      %{"user" =>
        %{
          "email" => "myshinynewemail@tld",
          "current_password" => context.user.password
        }
      })

    assert "/profiles/#{context.user.name}" == redirected_to(session)
    assert Repo.get!(User, context.user.id).email == "myshinynewemail@tld"
  end

  test "changing password", context do
    session = patch(context.session, "/profile",
      %{"user" =>
        %{
          "password" => "myshinynewpassword",
          "password_confirmation" => "myshinynewpassword",
          "current_password" => context.user.password
        }
      })

    assert "/profiles/#{context.user.name}" == redirected_to(session)
    assert Repo.get!(User, context.user.id).password_hash !=
      context.user.password_hash
  end

  describe "fails when" do
    test "current password is not provided", context do
      assert {:current_password, {"is required to confirm the changes", []}} in
        patch(context.session, "/profile",
          %{"user" =>
            %{
              "email" => "newemail@tld"
            }
          }).assigns[:user_changeset].errors

      assert {:current_password, {"is required to confirm the changes", []}} in
        patch(context.session, "/profile",
          %{"user" =>
            %{
              "email" => "newemail@tld",
              "current_password" => "not#{context.user.password}"
            }
          }).assigns[:user_changeset].errors
    end

    test "email is changed to an already used address", context do
      insert_user %{name: "somename",
        email: "thiscantbeused@anymore", password: "somepassword"}

      assert {:email, {"has already been used", []}} in
        patch(context.session, "/profile",
          %{"user" =>
            %{
              "email" => "thiscantbeused@anymore",
              "current_password" => context.user.password
            }
          }).assigns[:user_changeset].errors
    end

    test "new password doesn't match confirmation", context do
      assert {:password_confirmation,
          {"does not match confirmation", [validation: :confirmation]}} in
        patch(context.session, "/profile",
          %{"user" =>
            %{
              "password" => "myshinynewpassword",
              "password_confirmation" => "oopsdoesn'tmatch",
              "current_password" => context.user.password
            }
          }).assigns[:user_changeset].errors
    end
  end
end
