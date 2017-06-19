defmodule Fanuniverse.ImageUploadAction do
  alias Fanuniverse.Repo
  alias Fanuniverse.Image

  require Logger

  def perform(image) do
    image |> cache_upload |> persist
  end

  @doc """
  Assigns a unique name (cache string) to the image file and persists it.
  The cache string should be kept as a hidden form field "cache"; this will
  allow the user to resubmit a form multiple times without having to
  reattach the file (see `cached_url/1`)
  """
  defp cache_upload(%{"cache" => already_cached} = image) do
    {:ok, image, already_cached}
  end
  defp cache_upload(%{"image" => %Plug.Upload{path: path}} = image) do
    cache_string =
      :crypto.strong_rand_bytes(32)
      |> Base.encode64     # Base64 strings may contain path separators,
      |> sanitize_filename # `sanitize_filename` strips them away.

    cache_path = "priv/vidalia/cache/" <> cache_string

    case File.cp(path, cache_path) do
      :ok -> {:ok, image, cache_string}
      {:error, reason} -> {:error, image, reason}
    end
  end

  defp persist({:ok, image, cache_string}) do
    # A malicious user may inject path separators into cache_string,
    # `sanitize_filename` strips them away.
    cached_file = sanitize_filename(cache_string)
    changeset = Image.changeset(%Image{}, image)

    case Repo.insert(changeset) do
      {:ok, record} ->
        Dispatcher.Image.request_processing(record.id, cached_file)
        {:ok, record}
      {:error, changeset} ->
        {:error, changeset, cached_file, cache_url(cached_file)}
    end
  end
  defp persist({:error, image, reason}) do
    Logger.error("Error while peristing #{inspect(image)}, reason: #{reason}")
    :error
  end

  defp sanitize_filename(cache_string) do
    String.replace(cache_string, ~r/[^0-9A-Z+]/i, "")
  end

  defp cache_url(cache_string), do: "/upload/" <> cache_string
end
