defmodule Fanuniverse.ImageUploader do
  use Fanuniverse.Uploader

  import Dispatcher.Image, only: [request_processing: 2]

  require Logger

  @remote_image_max_size 30 * 1024 * 1024

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
  def cache_upload(%{"remote_image" => remote_url} = params) do
    cache_string = random_cache_string()
    download_opts = [path: cache_path(cache_string),
      max_file_size: @remote_image_max_size, timeout: 15_000]

    case Download.from(remote_url, download_opts) do
      {:ok, _} -> {:ok, params, cache_string}
      {:error, reason} -> {:error, params, reason}
     end
  end
  def cache_upload(%{"image" => %Plug.Upload{path: path}} = params) do
    cache_string = random_cache_string()

    case File.cp(path, cache_path(cache_string)) do
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
    Logger.error("#{reason} while peristing #{inspect(params)}")
    :error
  end
end
