defmodule Fanuniverse.TagUpdates do
  @tag_search_url Application.get_env(:fanuniverse,
    :services)[:sapphire_url_root] <> "/search"

  def tag_counts(tags) do
    Enum.map(tags, fn(tag) ->
      %{body: resp} = HTTPoison.get!(@tag_search_url, [], params: [q: tag])

      case Poison.decode!(resp) do
        [[_, count] | _] -> count
        _ -> 0
      end
    end)
  end
end
