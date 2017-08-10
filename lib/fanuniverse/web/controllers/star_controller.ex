defmodule Fanuniverse.Web.StarController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Star

  plug EnsureAuthenticated when action in [:toggle]

  def toggle(conn, params) do
    with {:ok, status, stars_count} <- Star.toggle(user(conn), params),
      do: json conn, %{status: status, stars: stars_count}
  end
end
