defmodule Fanuniverse.ImageIndex do
  @behaviour Elasticfusion.Index

  import Ecto.Query

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.User
  alias Fanuniverse.Star

  def index_name() do
    "image_index"
  end

  def document_type() do
    "image"
  end

  def settings() do
    %{number_of_shards: 1}
  end

  def mapping() do
    %{
      "id" => %{type: :integer},
      "tags" => %{type: :keyword},
      "stars" => %{type: :integer},
      "comments" => %{type: :integer},
      "width" => %{type: :integer},
      "height" => %{type: :integer},
      "suggested_by" => %{type: :keyword},
      "starred_by_ids" => %{type: :keyword},
      "created_at" => %{type: :date},
      "visible" => %{type: :boolean}
    }
  end

  def keyword_field() do
    "tags"
  end

  def queryable_fields() do
    ["id", "stars", "comments", "width", "height", "suggested_by", "created_at"]
  end

  def serialize(%Image{} = record) do
    suggested_by_name = from(u in User,
      select: u.name, where: u.id == ^record.suggested_by_id)
      |> Repo.one()
      |> String.downcase()

    starred_by_ids = from(s in Star,
      select: s.user_id, where: s.image_id == ^record.id)
      |> Repo.all()

    %{
      "id" => record.id,
      "tags" => record.tags.list,
      "stars" => record.stars_count,
      "comments" => record.comments_count,
      "width" => record.width,
      "height" => record.height,
      "created_at" => record.inserted_at,
      "visible" => record.processed,
      "suggested_by" => suggested_by_name,
      "starred_by_ids" => starred_by_ids
    }
  end
end
