defmodule Fanuniverse.CommentControllerTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.Comment

  test "creates a comment and returns comment listing" do
    image = insert(:image)

    session =
      test_user_session()
      |> post("/comments", %{"comment" =>
          %{"image_id" => image.id, "body" => "h"}})
      |> post("/comments", %{"comment" =>
          %{"image_id" => image.id, "body" => "hh"}})

    assert length(session.assigns.comments) == 2
    assert List.first(session.assigns.comments).body == "h"
    assert List.last(session.assigns.comments).body == "hh"
    assert List.first(session.assigns.comments).image_id == image.id
  end
end
