defmodule Fanuniverse.ImageIndex do
  use Elasticfusion.Index

  import Ecto.Query

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.User
  alias Fanuniverse.Star

  index_name "image_index"

  document_type "image"

  index_settings %{number_of_shards: 1}

  mapping %{
    id: %{type: :integer},
    tags: %{type: :keyword},
    stars: %{type: :integer},
    comments: %{type: :integer},
    width: %{type: :integer},
    height: %{type: :integer},
    suggested_by: %{type: :keyword},
    starred_by_ids: %{type: :keyword},
    created_at: %{type: :date},
    visible: %{type: :boolean}
  }

  keyword_field :tags

  queryable_fields [
    id: "id",
    stars: "stars",
    comments: "comments",
    width: "width",
    height: "height",
    created_at: "created at"
  ]

  def_transform "suggested by", fn(_, name, _) ->
    indexed_name = String.downcase(name)
    %{term: %{suggested_by: indexed_name}}
  end

  def_transform "in", fn
    (_, "my stars", %User{id: user_id}) ->
      %{term: %{starred_by_ids: user_id}}
    (_, _, _) ->
      %{}
  end

  serialize fn(%Image{} = record) ->
    suggested_by_name = from(u in User,
      select: u.name, where: u.id == ^record.suggested_by_id)
      |> Repo.one()
      |> String.downcase()

    starred_by_ids = from(s in Star,
      select: s.user_id, where: s.image_id == ^record.id)
      |> Repo.all()

    %{
      id: record.id,
      tags: record.tags.list,
      stars: record.stars_count,
      comments: record.comments_count,
      width: record.width,
      height: record.height,
      created_at: record.inserted_at,
      visible: record.processed,
      suggested_by: suggested_by_name,
      starred_by_ids: starred_by_ids
    }
  end
end
