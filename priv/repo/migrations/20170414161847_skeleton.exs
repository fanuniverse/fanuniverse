defmodule Fanuniverse.Repo.Migrations.Skeleton do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :tags, {:array, :text}
      add :source, :text, null: false, default: ""
      
      # image uploads ?
      
      # add :suggested_by_id, references(:users)
      
      add :stars_count, :integer, null: false, default: 0
      add :comments_count, :integer, null: false, default: 0
      
      add :width, :integer
      add :height, :integer
      add :phash, :text

      add :processed, :boolean, default: false

      add :merged_into_id, references(:images)

      timestamps
    end

    create index(:images, [:tags], using: :gin)
  end
end

