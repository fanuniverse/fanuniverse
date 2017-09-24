defmodule Fanuniverse.Workers.ImageIndexUpdate do
  use Toniq.Worker

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.ImageIndex

  @sapphire_url Application.get_env(:fanuniverse, :services)[:sapphire_url_root]

  def perform(args) do
    id = args |> Keyword.get(:id)
    added_tags = args |> Keyword.get(:added_tags, [])
    removed_tags = args |> Keyword.get(:removed_tags, [])

    Image
    |> Repo.get!(id)
    |> Elasticfusion.Document.index(ImageIndex)

    index_tags(added_tags, removed_tags)
  end

  def index_tags([], []), do: :ok
  def index_tags(add, remove) do
    HTTPoison.post!(@sapphire_url <> "/update", {:form,
      [add: Poison.encode!(add), remove: Poison.encode!(remove)]})
  end
end
