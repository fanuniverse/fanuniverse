defmodule Fanuniverse.Web.Admin.DashboardController do
  use Fanuniverse.Web, :controller

  def index(conn, _) do
    render conn, "index.html",
      unresolved_reports: 0 # TODO: add reports

    # TODO: integrate https://github.com/freecnpro/observerweb
    #       and RabbitMQ's management UI
  end
end
