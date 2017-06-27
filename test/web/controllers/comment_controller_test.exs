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

    [first, last] = session.assigns.comments

    assert first.body == "h"
    assert last.body == "hh"
    assert first.image_id == image.id
    assert first.user == %{test_user() | password: nil}
  end
end
