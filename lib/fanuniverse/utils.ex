defmodule Fanuniverse.Utils do
  def parse_integer(binary, default) when is_binary(binary) do
    case Integer.parse(binary) do
      {parsed, _} -> parsed
      _ -> default
    end
  end
  def parse_integer(integer, _) when is_integer(integer),
    do: integer
  def parse_integer(_, default),
    do: default
end
