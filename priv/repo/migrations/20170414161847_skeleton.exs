defmodule Fanuniverse.Repo.Migrations.Skeleton do
  use Ecto.Migration

  def change do
    users()
    images()
  end

  def users do
    create table(:users) do
      add :name, :text
      add :email, :text
      add :password_hash, :text

      timestamps()
    end

    create unique_index(:users, [:email])
    execute """
    CREATE UNIQUE INDEX users_lowercase_name_index
    ON users USING btree (lower(name));
    """

    create table(:user_profiles) do
      add :bio, :text, null: false, default: ""
      add :comments_count, :integer, null: false, default: 0

      add :user_id, references(:users, on_delete: :delete_all)
    end

    create unique_index(:user_profiles, [:user_id])
  end

  def images do
    create table(:images) do
      add :tags, {:array, :text}
      add :source, :text, null: false, default: ""

      add :suggested_by_id, references(:users)

      add :stars_count, :integer, null: false, default: 0
      add :comments_count, :integer, null: false, default: 0

      add :width, :integer
      add :height, :integer
      add :phash, :text
      add :ext, :text

      add :processed, :boolean, default: false

      add :merged_into_id, references(:images)

      timestamps()
    end

    create index(:images, [:tags], using: :gin)
  end
end
