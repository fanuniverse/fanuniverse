defmodule Fanuniverse.Web.StarController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.StarToggleAction, as: StarToggle

  plug EnsureAuthenticated when action in [:toggle]

  def toggle(conn, params) do
    with {:ok, status, stars_count} <-
            StarToggle.perform(params, user(conn)),
      do: json conn, %{status: status, stars: stars_count}
  end
end
