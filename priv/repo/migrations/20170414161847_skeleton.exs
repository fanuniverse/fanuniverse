defmodule Fanuniverse.Repo.Migrations.Skeleton do
  use Ecto.Migration

  def change do
    add_by_sql_script "functions/counter_cache_incr.sql"
    add_by_sql_script "functions/counter_cache_update.sql"

    # Ensure we're not in production (otherwise the extension is already there)
    if Code.ensure_loaded?(Mix),
      do: execute "CREATE EXTENSION pg_similarity;"

    users()
    images()
    comments()
    stars()
    reports()
  end

  def users do
    create table(:users) do
      add :name, :text
      add :email, :text
      add :password_hash, :text

      add :role, :text
      add :avatar_file_ext, :text

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

  def comments do
    create table(:comments) do
      add :body, :text
      add :user_id, references(:users)
      add :stars_count, :integer, null: false, default: 0

      # Polymorphic resources
      add :image_id, references(:images)
      add :user_profile_id, references(:user_profiles)

      timestamps()
    end

    # Ensure that any given comment belongs to exactly one resource
    create constraint(:comments, :belongs_to_integrity, check: """
    (
      (image_id IS NOT NULL)::integer +
      (user_profile_id IS NOT NULL)::integer
    ) = 1
    """)

    # Add a trigger for counter cache updates
    # NOTE: You need to manually edit the assoc function
    #       when adding new resource types.
    add_by_sql_script "functions/assoc_for_comment.sql"
    add_by_sql_script "triggers/comments_update_counter_cache.sql"

    create index(:comments, [:image_id],
      where: "image_id IS NOT NULL")
    create index(:comments, [:user_profile_id],
      where: "user_profile_id IS NOT NULL")
  end

  def stars do
    create table(:stars) do
      add :user_id, references(:users)

      # Polymorphic resources
      add :image_id, references(:images)
      add :comment_id, references(:comments)
    end

    # Ensure that any given star belongs to exactly one resource
    create constraint(:stars, :belongs_to_integrity, check: """
    (
      (image_id IS NOT NULL)::integer +
      (comment_id IS NOT NULL)::integer
    ) = 1
    """)

    # Add a trigger for counter cache updates
    # NOTE: You need to manually edit the assoc function
    #       when adding new resource types.
    add_by_sql_script "functions/assoc_for_star.sql"
    add_by_sql_script "triggers/stars_update_counter_cache.sql"

    add_by_sql_script "functions/star_toggle.sql"

    create index(:stars, [:image_id],
      where: "image_id IS NOT NULL")
    create index(:stars, [:comment_id],
      where: "comment_id IS NOT NULL")
  end

  def reports do
    create table(:reports) do
      add :creator_id, references(:users)
      add :resolver_id, references(:users)

      add :body, :text, null: false
      add :resolved, :boolean, default: false

      # Polymorphic resources
      add :image_id, references(:images)
      add :comment_id, references(:comments)

      timestamps()
    end

    # Ensure that any given report belongs to exactly one resource
    create constraint(:reports, :belongs_to_integrity, check: """
    (
      (image_id IS NOT NULL)::integer +
      (comment_id IS NOT NULL)::integer
    ) = 1
    """)
  end

  defp add_by_sql_script(path_relative_to_repo) do
    :code.priv_dir(:fanuniverse)
    |> Path.join("repo")
    |> Path.join(path_relative_to_repo)
    |> File.read!()
    |> execute()
  end
end
