defmodule Fanuniverse.AvatarUploadAction do
  @moduledoc """
  This module shares some similarities with
  `Fanuniverse.ImageUploadAction`; it is just written
  with more lax persistence requirements (no upload caching).
  """
  alias Fanuniverse.Repo
  alias Fanuniverse.User

  # Permitted file types for avatars
  # TODO: it might be a good idea to check file signatures
  # instead of extensions and ensure image validity.
  @upload_extensions %{
    "image/png" => "png",
    "image/jpeg" => "jpg",
    "image/gif" => "gif"
  }

  @max_file_size 300 * 1024 # 300kB (technically KiB but who cares amirite)

  def perform(%User{} = user, %Plug.Upload{} = upload) do
    ext = @upload_extensions[upload.content_type]

    with {:ok, ext} <- check_type(user, upload),
         :ok        <- check_file_size(user, upload),
         :ok        <- store_upload(user, upload, ext),
         {:ok, _}   <- set_avatar(user, ext),
      do: :ok
  end

  defp check_type(user, %Plug.Upload{content_type: content_type}) do
    case @upload_extensions[content_type] do
      ext when is_binary(ext) ->
        {:ok, ext}
      _ ->
        {:error, error_changeset(user,
          "image is not recognized. Supported formats are PNG, JPG, GIF")}
    end
  end

  defp check_file_size(user, %Plug.Upload{path: path}) do
    case File.stat(path) do
      {:ok, %{size: size}} when size < @max_file_size ->
        :ok
      _ ->
        {:error, error_changeset(user,
          "is too large; the file should be smaller than 300kB")}
    end
  end

  defp store_upload(user, %Plug.Upload{path: path}, ext) do
    destination = "priv/avatars/" <> user.name <> "." <> ext

    case File.cp(path, destination) do
      :ok ->
        :ok
      _ ->
        {:error, error_changeset(user,
          "could not be uploaded")}
    end
  end

  defp set_avatar(user, ext) do
    user
    |> Ecto.Changeset.change(%{avatar_file_ext: ext})
    |> Repo.update
  end

  defp error_changeset(user, message) do
    changeset =
      user
      |> User.changeset()
      |> Ecto.Changeset.add_error(:avatar, message)

    %{changeset | action: :update}
  end
end
