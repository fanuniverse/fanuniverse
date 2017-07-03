defmodule Auth.Plug.EnsureAuthenticated do
  @moduledoc """
  This plug redirects to the sign up path and shows an error message
  if user is not authenticated. It needs to be included after
  `Auth.Plug.LoadAunthenticatedUser`.

  ## Examples

      defmodule Fanuniverse.Web.Controller do
        use Fanuniverse.Web, :controller
        plug EnsureAuthenticated when action in [:create, :destroy]
      end

      # (assuming `EnsureAuthenticated` is aliased in `Fanuniverse.Web`)
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn |> Phoenix.Controller.redirect(to: "/sign_up") |> halt
    end
  end
end
