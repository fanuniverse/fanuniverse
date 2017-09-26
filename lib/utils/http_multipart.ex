defmodule Utils.HTTPMultipart do
  @moduledoc """
  A tiny wrapper for multipart HTTP requests/responses
  built on top of hackney.
  """

  def post_multipart(url, fields, files) when is_binary(url) do
    fields = Enum.map(fields, fn({name, value}) ->
      {name, value, [{"content-type", "text/plain"}]}
    end)
    files = Enum.map(files, fn({name, path}) ->
      {:file, path, {"form-data", [{"name", ~s("#{name}")}]}, []}
    end)

    :hackney.post(url, [], {:multipart, fields ++ files}, recv_timeout: 4 * 60 * 1000)
  end

  def receive_multipart({:ok, 200, headers, client}) do
    case find_header(headers, "content-type") do
      "multipart/form-data" <> _ ->
        receive_multipart({:stream, client}, nil, nil, [])
      _ ->
        {:error, :missing_content_type}
    end
  end
  def receive_multipart(error),
    do: {:error, error}
  def receive_multipart({:stream, client} = stream, part_name, part_acc, parts) do
    case :hackney.stream_multipart(client) do
      {:headers, headers} ->
        part_name = content_disposition_name(headers)
        receive_multipart(stream, part_name, [], parts)
      {:body, chunk} ->
        receive_multipart(stream, part_name, [chunk | part_acc], parts)
      :end_of_part ->
        part = {part_name, Enum.reverse(part_acc)}
        receive_multipart(stream, nil, nil, [part | parts])
      :eof ->
        {:ok, Enum.into(parts, %{})}
    end
  end

  defp find_header(headers, header_name) do
    Enum.find_value(headers, fn({name, value}) ->
      String.downcase(name) == header_name && value
    end)
  end

  defp content_disposition_name(headers) do
    content_disposition = find_header(headers, "content-disposition")
    [_, name] = Regex.run(~r/;\s*name="(.+?)"/, content_disposition)
    
    name
  end
end
