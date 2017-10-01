defmodule Fanuniverse.Web.CommentView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.Comment

  def js_comments(conn, resource) do
    content_tag :div, "", id: "comments",
      data_commentable_url: commentable_url(conn, resource)
  end

  def commentable_url(conn, resource) do
    {resource_key, resource_id} = Comment.resource_key_and_id(resource)

    comment_path(conn, :index, %{resource_key => resource_id})
  end
end
