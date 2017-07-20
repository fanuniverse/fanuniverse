defmodule Fanuniverse.Web.Admin.ReportController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Report

  def index(conn, _) do
    with :ok <- authorize(conn, :access, :admin) do
      {:ok, pagination, reports} = Repo.paginate(
        Report.unresolved(), conn.params,
        [default_per_page: 20, max_per_page: 50])

      render(conn, "index.html", reports: reports, pagination: pagination)
    end
  end

  def resolve(conn, %{"id" => report_id}) do
    with :ok <- authorize(conn, :access, :admin) do
      {:ok, _} =
        Report
        |> Repo.get!(report_id)
        |> Report.resolve(user(conn))

      conn
      |> put_flash(:info, "Report has been resolved.")
      |> redirect(to: "/")
    end
  end
end
