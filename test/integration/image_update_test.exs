defmodule Fanuniverse.ImageUpdateIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo

  setup do
    {:ok, %{session: test_user_session()}}
  end

  test "updating image tags", %{session: session} do
    image = insert(:image,
      %{tags: "(artist) a, (fandom) su, ruby"})

    # Tags are compared against tag_cache,
    new_tags =
      "(artist) a, (fandom) su, ruby, sapphire"
    session =
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
    session =
      patch(session, "/images/#{image.id}", %{"image" =>
        %{"tags" => new_tags, "tag_cache" => tag_cache}})

    assert to_string(Repo.reload!(image).tags) == should_become
  end
end
