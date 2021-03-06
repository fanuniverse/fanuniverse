defmodule Fanuniverse.Image.Tags do
  @behaviour Ecto.Type

  import Enum, only: [any?: 2, map: 2, reject: 2]
  import String, only: [split: 2, starts_with?: 2]

  defmodule Wrapper do
    defstruct list: []
  end

  defimpl String.Chars, for: Wrapper do
    def to_string(%Wrapper{list: tags}),
      do: Enum.join(tags, ", ")
  end

  defimpl Phoenix.HTML.Safe, for: Wrapper do
    def to_iodata(wrapper),
      do: Phoenix.HTML.Safe.to_iodata(to_string(wrapper))
  end

  defimpl Enumerable, for: Wrapper do
    def reduce(%Wrapper{list: tags}, acc, fun),
      do: Enumerable.reduce(tags, acc, fun)

    def member?(%Wrapper{list: tags}, elem),
      do: Enumerable.member?(tags, elem)

    def count(%Wrapper{list: tags}),
      do: Enumerable.count(tags)
  end

  def type, do: {:array, :string}

  def cast(tag_string) when is_binary(tag_string),
    do: {:ok, %Wrapper{list: parse(tag_string)}}
  def cast(tags) when is_list(tags),
    do: {:ok, %Wrapper{list: tags}}

  def load(tags) when is_list(tags),
    do: {:ok, %Wrapper{list: tags}}

  def dump(%Wrapper{list: tags}),      do: {:ok, tags}
  def dump(tags) when is_list(tags),   do: {:ok, tags}
  def dump(tags) when is_binary(tags), do: cast(tags)

  def validate(changeset) do
    Ecto.Changeset.validate_change(changeset, :tags,
      fn(:tags, %Wrapper{list: tags}) ->
        []
        |> validate_length(tags)
        |> validate_prefix(tags, "artist: ",
            "should include the artist, e.g. artist: somebody")
        |> validate_prefix(tags, "fandom: ",
            "should include the fandom, e.g. fandom: some show")
      end)
  end

  def update(%Wrapper{list: current}, new_tag_string, compare_against)
      when is_binary(new_tag_string) and is_binary(compare_against) do
    new_tags = parse(new_tag_string)
    old_tags = parse(compare_against)

    added = new_tags -- old_tags
    removed = old_tags -- new_tags

    new = (current ++ added) -- removed

    {new, added, removed}
  end
  def update(%Wrapper{list: current}, _, _),
    do: {current, [], []}

  defp validate_length(errors, tags) when length(tags) < 3,
    do: [{:tags, "should include the artist and the fandom,\
      as well as describe the image"} | errors]
  defp validate_length(errors, _),
    do: errors

  defp validate_prefix(errors, tags, prefix, message) do
    if any?(tags, fn(t) -> starts_with?(t, prefix) end),
      do: errors, else: [{:tags, message} | errors]
  end

  defp parse(tag_string) do
    tag_string
    |> split(",")
    |> map(&normalize/1)
    |> reject(&(&1 == ""))
  end

  defp normalize(tag_name) do
    tag_name
    |> String.trim
    |> String.downcase
    |> String.replace(~r/\s\s+/, " ")
    |> String.replace(~r/[´′‘’‚‛]/u, "'")
    |> String.replace(~r/[″“”„‟]/u, "\"")
  end
end
