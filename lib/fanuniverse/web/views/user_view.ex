defmodule Fanuniverse.Web.UserView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.User

  def avatar_url(%User{avatar_file_ext: nil}) do
    "/no-avatar.svg?v1"
  end
  def avatar_url(%User{name: name, avatar_file_ext: ext}) do
    root = Application.get_env(:fanuniverse, :avatar_url_root)
    root <> "/" <> name <> "." <> ext
  end
end
