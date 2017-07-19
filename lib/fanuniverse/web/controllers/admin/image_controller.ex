defmodule Fanuniverse.Web.Admin.ImageController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Image

  def merge(conn, %{"source" => source_id, "target" => target_id}) do
    with :ok <- authorize(conn, :access, :admin) do
      source = Repo.get!(Image, source_id)
      target = Repo.get!(Image, target_id)

      render conn, "merge.html", source: source, target: target
    end
  end

  def commit_merge(_conn, %{"source" => _source_id, "target" => _target_id}),
    do: raise "Not implemented" # FIXME
end
