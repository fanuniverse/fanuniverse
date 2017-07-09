defmodule Fanuniverse.ImageUploader do
  import Dispatcher.Image, only: [request_processing: 2]

  require Logger

  def upload(params, insert_fun) when is_function(insert_fun, 0) do
    params
    |> cache_upload()
    |> persist(insert_fun)
  end

  @doc """
  Assigns a unique name (cache string) to the image file and persists it.
  The cache string should be kept as a hidden form field "cache"; this will
  allow the user to resubmit a form multiple times without having to
  reattach the file (see `cached_url/1`)
  """
  def cache_upload(%{"cache" => already_cached} = params) do
    {:ok, params, already_cached}
  end
  def cache_upload(%{"image" => %Plug.Upload{path: path}} = params) do
    cache_string =
      :crypto.strong_rand_bytes(32)
      |> Base.encode64     # Base64 strings may contain path separators,
      |> sanitize_filename # `sanitize_filename` strips them away.

    cache_path = "priv/vidalia/cache/" <> cache_string

    case File.cp(path, cache_path) do
      :ok -> {:ok, params, cache_string}
      {:error, reason} -> {:error, params, reason}
    end
  end

  def persist({:ok, _params, cache_string}, insert_fun) do
    # A malicious user may inject path separators into the
    # cache string; `sanitize_filename` strips them away.
    cached_file = sanitize_filename(cache_string)

    case insert_fun.() do
      {:ok, %{id: id} = record} ->
        request_processing(id, cached_file)
        {:ok, record}
      {:error, changeset} ->
        {:error, changeset, cached_file, cache_url(cached_file)}
    end
  end
  def persist({:error, params, reason}, _) do
    Logger.error("Error while peristing #{inspect(params)}, reason: #{reason}")
    :error
  end

  defp sanitize_filename(cache_string) do
    String.replace(cache_string, ~r/[^0-9A-Z+]/i, "")
  end

  defp cache_url(cache_string), do:
    Application.get_env(:fanuniverse, :image_cache_root) <> "/" <> cache_string
end
