defmodule Fanuniverse.Image.Tags do
  @behaviour Ecto.Type

  import Enum, only: [any?: 2, map: 2, reject: 2]
  import String, only: [split: 2, starts_with?: 2]

  def type, do: {:array, :string}

  def cast(tag_string) when is_binary(tag_string), do: {:ok, parse(tag_string)}

  def load(tags) when is_list(tags), do: {:ok, Enum.join(tags, ", ")}

  def dump(tags) when is_binary(tags), do: cast(tags)
  def dump(tags) when is_list(tags), do: {:ok, tags}

  def validate(changeset) do
    Ecto.Changeset.validate_change(changeset, :tags, fn(:tags, tags) ->
      []
      |> validate_length(tags)
      |> validate_prefix(tags, "(artist) ",
          "should include the artist, e.g. (artist) somebody")
      |> validate_prefix(tags, "(fandom) ",
          "should include the fandom, e.g. (fandom) some show")
    end)
  end

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
