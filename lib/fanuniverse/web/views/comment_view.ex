defmodule Fanuniverse.Web.CommentView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.Comment

  def js_comments(conn, resource) do
    {resource_key, resource_id} = Comment.resource_key_and_id(resource)
    url = comment_path(conn, :index, %{resource_key => resource_id})

    content_tag :div, "", data_commentable_url: url, id: "comments"
  end
end
