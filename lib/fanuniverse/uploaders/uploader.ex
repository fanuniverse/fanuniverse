defmodule Fanuniverse.Uploader do
  @moduledoc """
  A mixin for uploader modules, which handle file storage,
  schema changes, and optionally file processing.
  """

  defmacro __using__(_) do
    quote do
      import Fanuniverse.Uploader
    end
  end

  @doc """
  To persist the uploaded file across form resubmissions, uploaders
  may temporarily store it in a cache.

  This function generates a random cache string (filename). Use
  `cache_path/1` to get an absolute path for file operations.
  """
  def random_cache_string,
    do: Base.encode64(:crypto.strong_rand_bytes(32))

  def cache_path(cache_string) do
    cache_string = sanitize_filename(cache_string)
    cache_root = Application.get_env(:fanuniverse, :cache_fs_path)
    Path.join(cache_root, cache_string)
  end

  @doc """
  Strips path separators, which are valid characters in the Base64 encoding
  (and can be injected into the cache string by a malicious user).
  """
  def sanitize_filename(cache_string),
    do: String.replace(cache_string, ~r/[^0-9A-Z+]/i, "")

  def cache_url(cache_string),
    do: Application.get_env(:fanuniverse, :cache_url_root) <> "/" <> cache_string

  @doc """
  Given a `Plug.Upload` struct and a map of
  `%{content_type_binary => extension_binary}`, returns:

  * `{:ok, extension_binary}` if upload content type is found in the map,
  * `{:error, :unsupported_content_type}` otherwise.
  """
  def check_type(%Plug.Upload{content_type: upload_type}, supported_types) do
    case supported_types do
      %{^upload_type => ext} ->
        {:ok, ext}
      _ ->
        {:error, :unsupported_content_type}
    end
  end

  @doc """
  Given a `Plug.Upload` struct and an integer specifying maximum
  allowed file size in bytes, returns:

  * `:ok` if upload size is less than the specified maximum size,
  * `{:error, :file_too_large}` otherwise.
  """
  def check_file_size(%Plug.Upload{path: path}, max_size) do
    case File.stat(path) do
      {:ok, %{size: size}} when size < max_size ->
        :ok
      _ ->
        {:error, :file_too_large}
    end
  end
end
