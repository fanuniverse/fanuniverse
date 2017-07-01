defmodule Fanuniverse.Web.CommentController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Comment

  plug :put_layout, false
  plug EnsureAuthenticated when action in [:create]

  def index(conn, params) do
    comment_listing conn, Comment.query_for_resource(params)
  end

  def create(conn, %{"comment" => comment_params}) do
    changeset = Comment.changeset(
      %Comment{user: user(conn)}, comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        {resource_param, resource_id} =
          Comment.resource_key_and_id(comment)
        comment_query =
          Comment.query_for_resource(comment)

        conn =
          update_in(conn.params, &(
            &1
            |> Map.take(["page", "per_page"])
            |> Map.put(resource_param, resource_id)))

        comment_listing(conn, comment_query)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Fanuniverse.Web.LayoutView, "errors.html",
            changeset: changeset)
    end
  end

  defp comment_listing(conn, comment_query) do
    {:ok, pagination, comments} =
      comment_query
      |> preload(:user)
      |> order_by(desc: :id)
      |> Repo.paginate(conn.params, [default_per_page: 10, max_per_page: 50])

    render conn, "index.html", comments: comments, pagination: pagination
  end
end
