defmodule Fanuniverse.ImageSearchIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo

  setup do
    {:ok, %{session: test_user_session()}}
  end

  test "search results only include processed images", %{session: session} do
    image = insert(:image, %{tags: "artist: a, fandom: su, blue diamond"})
    Elasticfusion.Document.index(image, Fanuniverse.ImageIndex)
    refresh_index(Fanuniverse.ImageIndex)

    session = get(session, "/", %{"q" => "blue diamond"})
    assert session.assigns.images == []

    Fanuniverse.ImageProcessingUpdateAction.perform!(
      image.id, 300, 600, "1001001", "png")
    refresh_index(Fanuniverse.ImageIndex)

    session = get(session, "/", %{"q" => "blue diamond, width: 300, height: 600"})
    assert length(session.assigns.images) == 1
    assert List.first(session.assigns.images).id == image.id
  end
end
