defmodule Fanuniverse.ImageUpdateIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  setup do
    {:ok, %{session: test_user_session()}}
  end

  test "metadata updates trigger an ES document reindex", %{session: session} do
    image = insert(:image,
      %{tags: "(artist) art, (fandom) su, ruby"})

    new_tags =
      "(artist) art, (fandom) su, ruby, sapphire"
    patch(session, "/images/#{image.id}", %{"image" =>
      %{"tags" => new_tags, "tag_cache" => to_string(image.tags)}})

    refresh_index(Fanuniverse.ImageIndex)

    assert {:ok, [to_string(image.id)], 1} ==
      Elasticfusion.Search.find_ids(
        %{query: %{bool: %{must: [
          %{term: %{tags: "sapphire"}},
          %{term: %{id: image.id}}
        ]}}}, Fanuniverse.ImageIndex)
  end

  test "tag updates are based on a new-vs-cached comparison", %{session: session} do
    image = insert(:image,
      %{tags: "(artist) a, (fandom) su, ruby"})

    # Tags are compared against tag_cache,
    new_tags =
      "(artist) a, (fandom) su, ruby, sapphire"
    patch(session, "/images/#{image.id}", %{"image" =>
      %{"tags" => new_tags, "tag_cache" => to_string(image.tags)}})

    assert to_string(Repo.reload!(image).tags) == new_tags

    # ...which controls what tags are added
    new_tags =
      "(artist) a, (fandom) su, ruby, sapphire, fusion, garnet"
    tag_cache =
      "(artist) a, (fandom) su, ruby, sapphire, fusion"
    should_become =
      "(artist) a, (fandom) su, ruby, sapphire, garnet"
    patch(session, "/images/#{image.id}", %{"image" =>
      %{"tags" => new_tags, "tag_cache" => tag_cache}})

    assert to_string(Repo.reload!(image).tags) == should_become

    # ...and removed
    new_tags =
      "(artist) a, (fandom) su, ruby"
    tag_cache =
      "(artist) a, (fandom) su, ruby, garnet"
    should_become =
      "(artist) a, (fandom) su, ruby, sapphire"
    patch(session, "/images/#{image.id}", %{"image" =>
      %{"tags" => new_tags, "tag_cache" => tag_cache}})

    assert to_string(Repo.reload!(image).tags) == should_become

    # ...and which is required
    new_tags =
      "(artist) a, (fandom) su, sapphire"
    should_become =
      "(artist) a, (fandom) su, ruby, sapphire"
    patch(session, "/images/#{image.id}", %{"image" =>
      %{"tags" => new_tags}})

    assert to_string(Repo.reload!(image).tags) == should_become
  end

  test "image metadata is versioned", %{session: session} do
    image = insert(:image,
      %{tags: "(artist) a, (fandom) su, ruby"})

    new_tags =
      "(artist) a, (fandom) su, ruby, sapphire"
    patch(session, "/images/#{image.id}", %{"image" =>
      %{"tags" => new_tags, "tag_cache" => to_string(image.tags)}})

    last_version = Repo.one(
      from v in PaperTrail.Version,
      where: v.item_id == ^image.id,
      order_by: [desc: :inserted_at],
      preload: :user)
    %PaperTrail.Version{
      item_changes: %{"tags" => %{"list" => version_tags}},
      user: %User{id: user_id}} = last_version

    assert version_tags == Repo.reload!(image).tags.list
    assert user_id == Auth.Helpers.user(session).id
  end
end
