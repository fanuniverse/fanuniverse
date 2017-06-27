defmodule Fanuniverse.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Fanuniverse.Web, :controller
      use Fanuniverse.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller,
        namespace: Fanuniverse.Web

      alias Fanuniverse.Repo
      alias Auth.Plug.EnsureAuthenticated
      alias Auth.Plug.EnsureNotAuthenticated

      import Ecto
      import Ecto.Query
      import Fanuniverse.Web.Router.Helpers
      import Fanuniverse.Web.Gettext
      import Auth.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/fanuniverse/web/templates",
        namespace: Fanuniverse.Web

      use Phoenix.HTML

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [
        get_csrf_token: 0, get_flash: 2, view_module: 1, action_name: 1]

      import Fanuniverse.Web.Router.Helpers
      import Fanuniverse.Web.Gettext
      import Auth.Helpers

      import Fanuniverse.Web.ErrorHelpers
      import Fanuniverse.Web.HTMLHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Fanuniverse.Repo
      import Ecto
      import Ecto.Query
      import Fanuniverse.Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
