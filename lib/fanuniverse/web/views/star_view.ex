defmodule Fanuniverse.Web.StarView do
  use Fanuniverse.Web, :view

  alias Fanuniverse.Star

  def js_stars(conn, resource_or_resources) do
    resources = List.wrap(resource_or_resources)
    user = user(conn)

    with {key, ids} <- Star.for_uniform_resources_and_user(resources, user),
      do: content_tag :div, "",
            data_starrable_key: key,
            data_starrable_ids: Poison.encode!(ids)
  end
end
