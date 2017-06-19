defmodule Fanuniverse.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
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
  end

  def down do
    drop table(:users)
    drop index(:users, [:email])
    execute """
    DROP INDEX users_lowercase_name_index;
    """
  end
end
