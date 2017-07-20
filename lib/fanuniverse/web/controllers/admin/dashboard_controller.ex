defmodule Fanuniverse.Web.Admin.DashboardController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Repo
  alias Fanuniverse.Report

  # TODO: integrate https://github.com/freecnpro/observerweb and RabbitMQ's UI
  def index(conn, _) do
    with :ok <- authorize(conn, :access, :admin), do:
      render(conn, "index.html", reports: Repo.count(Report.unresolved()))
  end
end
