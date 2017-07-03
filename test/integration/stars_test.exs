defmodule Fanuniverse.StarsIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.Image

  setup do
    {:ok, %{session: test_user_session()}}
  end

  test "logged out users cannot toggle stars" do
    image = insert(:image)

    assert (build_conn()
            |> post("/stars/toggle", %{image_id: image.id})
            |> redirected_to(302)) == "/sign_up"

    assert Repo.get!(Image, image.id).stars_count == 0
  end

  test "users can toggle stars on a given resource", %{session: session} do
    image = insert(:image)

    assert (session
            |> post("/stars/toggle", %{image_id: image.id})
            |> json_response(200)) ==
      %{"status" => "added", "stars" => 1}

    assert Repo.get!(Image, image.id).stars_count == 1

    assert (session
            |> post("/stars/toggle", %{image_id: image.id})
            |> json_response(200)) ==
      %{"status" => "removed", "stars" => 0}

    assert Repo.get!(Image, image.id).stars_count == 0
  end

  test "toggling a star triggers a document reindex", %{session: session} do
    image = insert(:image)

    assert (session
            |> post("/stars/toggle", %{image_id: image.id})
            |> json_response(200)) ==
      %{"status" => "added", "stars" => 1}

    refresh_index(Fanuniverse.ImageIndex)

    assert {:ok, [to_string(image.id)], 1} ==
      Elasticfusion.Search.find_ids(
        %{query: %{bool: %{must: [
          %{term: %{stars: 1}},
          %{term: %{id: image.id}}
        ]}}}, Fanuniverse.ImageIndex)
  end
end
