defmodule Fanuniverse.Web.CommentController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Comment
  alias Fanuniverse.Image

  plug :put_layout, false
  plug EnsureAuthenticated when action in [:create]

  def index(conn, params) do
    comment_listing conn, Comment.query_for_resource(params)
  end

  def create(conn, %{"comment" => comment_params} = params) do
    changeset = Comment.changeset(
      %Comment{user: user(conn)}, comment_params)

    with {:ok, comment} <- Repo.insert(changeset) do
      comment_query =
        Comment.query_for_resource(comment)
      conn =
        update_in(conn.params, &Map.put(&1, "comment_id", comment.id))

      comment_listing(conn, comment_query)
    end
  end

  defp comment_listing(conn, comment_query) do
    comments =
      comment_query
      |> preload(:user)
      |> Repo.all()

    render conn, "index.html", comments: comments
  end
end
