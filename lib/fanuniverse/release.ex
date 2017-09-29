defmodule Fanuniverse.Release do
  @app :fanuniverse

  def prepare do
    {:ok, _} = Application.ensure_all_started(@app)

    %{elasticsearch: create_elasticsearch_indexes(), db: migrate()}
  end

  def create_elasticsearch_indexes do
    [
      Fanuniverse.ImageIndex
    ]
    |> Enum.map(&create_elasticsearch_index/1)
  end

  def create_elasticsearch_index(index) do
    case Elasticfusion.IndexAPI.create_index(index) do
      :ok ->
        {:ok, index}
      {:error, %{body: %{"error" => %{"type" => "index_already_exists_exception"}}}} ->
        {:ok, index}
      {:error, %{body: %{"error" => %{"root_cause" => [%{"reason" => reason}]}}}} ->
        {:error, index, reason}
      {:error, other_reason} ->
        {:error, index, other_reason}
    end
  end

  def migrate do
    Ecto.Migrator.run(Fanuniverse.Repo, migrations_path(), :up, all: true)
  end

  defp migrations_path,
    do: Application.app_dir(@app, "priv/repo/migrations")
end
