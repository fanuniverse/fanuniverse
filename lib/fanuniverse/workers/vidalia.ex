defmodule Fanuniverse.Workers.Vidalia do
  use Toniq.Worker, max_concurrency: 1

  import Path, only: [join: 2]
  import Utils.HTTPMultipart, only: [post_multipart: 3, receive_multipart: 1]

  alias Fanuniverse.Image

  @vidalia_url Application.get_env(:fanuniverse, :services)[:vidalia_url_root]

  @storage_root Application.get_env(:fanuniverse, :image_fs_path)

  @allowed_image_types %{
    "image/png"  => "png",
    "image/jpeg" => "jpg",
    "image/gif"  => "gif"
  }

  @doc """
  Moves a given image from cache to persistent storage
  and process it. Raises exceptions instead of returning
  status tuples so as to fit in the Toniq worker model.

  Processing depends on the type of the image;
  see manifests below.
  """
  def perform(id: id, cache_path: cache_path) do
    {:ok, ext} =
      read_image_ext(cache_path)
    {storage_dir, source_name} =
      move_to_storage!(id, ext, cache_path)
    analyzed =
      process!(ext, storage_dir, source_name)
    {:ok, _} =
      Image.update_after_processing(id, analyzed)
  end

  @image_versions ~w(thumbnail preview)
  @image_manifest Poison.encode!(%{transforms: [
    %{
      kind: :downsize_to_width,
      name: "thumbnail",
      width: 300
    },
    %{
      kind: :downsize_to_width,
      name: "preview",
      width: 1280
    }
  ]})

  @gif_manifest Poison.encode!(%{transforms: [
    %{
      kind: :gif_to_h264,
      name: "mp4",
      crf: 22,
      preset: "slow"
    },
    %{
      kind: :gif_to_webm,
      name: "webm",
      crf: 22,
      bitrate: 1200
    },
    %{
      kind: :gif_first_frame_jpeg,
      name: "poster",
      quality: 80
    }
  ]})

  defp move_to_storage!(id, ext, cache_path) do
    storage_dir = join(@storage_root, to_string(id))
    source_name = "source.#{ext}"

    :ok = File.mkdir_p(storage_dir)
    :ok = File.rename(cache_path, join(storage_dir, source_name))

    {storage_dir, source_name}
  end

  defp process!(ext, storage_dir, source_name) when ext in ~w(jpg png) do
    {:ok, response} =
      @vidalia_url
      |> post_multipart([{"manifest", @image_manifest}],
                        [{"image", join(storage_dir, source_name)}])
      |> receive_multipart()

    for version <- @image_versions do
      version_path = join(storage_dir, version <> "." <> ext)

      case response[version] do
        # Vidalia returns an empty blob if the source image
        # has smaller dimensions than the requested version.
        [] ->
          File.ln_s!(source_name, version_path)
        resized_version ->
          File.write!(version_path, resized_version)
      end
    end

    return_analyzed(response, ext)
  end
  defp process!(ext, storage_dir, source_name) when ext == "gif" do
    {:ok, response} =
      @vidalia_url
      |> post_multipart([{"manifest", @gif_manifest}],
                        [{"image", join(storage_dir, source_name)}])
      |> receive_multipart()

    File.write!(join(storage_dir, "rendered.mp4"), response["mp4"])
    File.write!(join(storage_dir, "rendered.webm"), response["webm"])
    File.write!(join(storage_dir, "poster.jpg"), response["poster"])

    return_analyzed(response, ext)
  end

  defp return_analyzed(processing_response, ext) do
    processing_response["analyzed"]
    |> Poison.decode!()
    |> Map.put("ext", ext)
  end

  # TODO: move this logic to the uploader
  defp read_image_ext(path) do
    {mime_output, 0} =
      System.cmd("file", ["--mime-type", path])
    mime_type =
      mime_output
      |> String.replace("\n", "")
      |> String.split(": ")
      |> List.last()

    case @allowed_image_types do
      %{^mime_type => ext} ->
        {:ok, ext}
      _ ->
        {:error, :unsupported_content_type, mime_type}
    end
  end
end
