defmodule Repo.Migrations.AddVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :event,        :text, null: false
      add :item_type,    :text, null: false
      add :item_id,      :integer
      add :item_changes, :map, null: false
      add :originator_id, references(:users)
      add :origin,       :text
      add :meta,         :map

      add :inserted_at,  :utc_datetime, null: false
    end

    create index(:versions, [:originator_id])
    create index(:versions, [:item_id, :item_type])
  end
end
