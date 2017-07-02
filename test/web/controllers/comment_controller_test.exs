defmodule Fanuniverse.CommentControllerTest do
  use Fanuniverse.Web.ConnCase

  test "creates a comment and returns comment listing" do
    image = insert(:image)

    session =
      test_user_session()
      |> post("/comments", %{"comment" =>
          %{"image_id" => image.id, "body" => "h"}})
      |> post("/comments", %{"comment" =>
          %{"image_id" => image.id, "body" => "hh"}})

    assert session.params == %{image_id: image.id}

    assert Repo.get!(Fanuniverse.Image, image.id).comments_count == 2

    assert length(session.assigns.comments) == 2

    [first, last] = session.assigns.comments

    assert first.body == "hh"
    assert last.body == "h"
    assert first.image_id == image.id
    assert first.user == %{test_user() | password: nil}
  end
end
