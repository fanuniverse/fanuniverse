defmodule Fanuniverse.Web.UserProfileView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.User

  def render("title", %{action_name: :show, user: %User{name: name}}),
    do: "@" <> name
  def render("title", %{action_name: :edit}),
    do: "Editing your profile"
end
