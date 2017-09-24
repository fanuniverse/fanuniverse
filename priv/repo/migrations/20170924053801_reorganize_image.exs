defmodule Fanuniverse.Repo.Migrations.ReorganizeImage do
  use Ecto.Migration

  def change do
    rename table(:images), :phash, to: :hash
  end
end
