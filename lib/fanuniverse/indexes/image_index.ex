defmodule Fanuniverse.ImageIndex do
  @behaviour Elasticfusion.Index

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

  def serialize(%Fanuniverse.Image{} = record) do
    %{
      "id" => record.id,
      "tags" => record.tags,
      "stars" => record.stars_count,
      "comments" => record.comments_count,
      "width" => record.width,
      "height" => record.height,
      "created_at" => record.inserted_at,
      "visible" => record.processed
      # TODO: suggested_by, starred_by_ids
    }
  end
end
