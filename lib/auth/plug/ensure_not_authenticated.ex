defmodule Auth.Plug.EnsureNotAuthenticated do
  @moduledoc """
  Unlike `Auth.Plug.EnsureAuthenticated`, this plug redirects
  redirects to the home path if user _is_ authenticated. It
  needs to be included after `Auth.Plug.LoadAunthenticatedUser`.

  ## Examples

      defmodule Fanuniverse.Web.Controller do
        use Fanuniverse.Web, :controller
        plug EnsureNotAuthenticated when action in [:sign_up]
      end

      # (assuming `EnsureNotAuthenticated` is aliased in `Fanuniverse.Web`)
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn |> Phoenix.Controller.redirect(to: "/") |> halt
    else
      conn
    end
  end
end
