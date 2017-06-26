defmodule Fanuniverse.Web.CommentController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Comment
  alias Fanuniverse.Image

  def index(conn, params) do
    comment_listing conn, Comment.single_resource_query(params)
  end

  def create(conn, %{"comment" => comment_params} = params) do
    changeset = Comment.changeset(%Comment{}, comment_params)

    with {:ok, comment} <- Repo.insert(changeset) do
      comment_query =
        Comment.single_resource_query(comment)
      conn =
        update_in(conn.params, &Map.put(&1, "comment_id", comment.id))

      comment_listing(conn, comment_query)
    end
  end

  defp comment_listing(conn, comment_query) do
    render conn, "index.html", comments: Repo.all(comment_query)
  end
end
