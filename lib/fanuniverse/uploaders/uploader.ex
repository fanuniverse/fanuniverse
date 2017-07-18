defmodule Fanuniverse.Uploader do
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
    Path.join([:code.priv_dir(:fanuniverse), "cache", cache_string])
  end

  @doc """
  Strips path separators, which are valid characters in the Base64 encoding
  (and can be injected into the cache string by a malicious user).
  """
  def sanitize_filename(cache_string),
    do: String.replace(cache_string, ~r/[^0-9A-Z+]/i, "")

  def cache_url(cache_string),
    do: Application.get_env(:fanuniverse, :cache_url_root) <> "/" <> cache_string
end
