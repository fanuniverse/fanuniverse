defmodule Fanuniverse.Web.Admin.DashboardController do
  use Fanuniverse.Web, :controller

  # TODO: integrate https://github.com/freecnpro/observerweb and RabbitMQ's UI
  def index(conn, _) do
    with :ok <- authorize(conn, :access, :admin), do:
      render(conn, "index.html", unresolved_reports: 0)
  end
end
