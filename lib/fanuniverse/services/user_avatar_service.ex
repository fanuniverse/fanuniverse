defmodule Fanuniverse.UserAvatarService do
  @moduledoc """
  This service exposes two functions, `add/2` and `remove/1`,
  for adding and removing user avatars. They handle file storage
  and schema changes.
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

  @max_file_size 300 * 1024 # 300kB

  defp avatar_path(%User{name: name}, ext) do
    avatar_root = Application.get_env(:fanuniverse, :avatar_fs_path)
    Path.join(avatar_root, name <> "." <> ext)
  end

  def add(%User{} = user, %Plug.Upload{} = upload) do
    with {:ok, ext} <- check_type(user, upload),
         :ok        <- check_file_size(user, upload),
         :ok        <- store_upload(user, upload, ext),
         {:ok, _}   <- set_avatar(user, ext),
      do: :ok
  end

  def remove(%User{} = user) do
    with :ok      <- remove_stored_upload(user),
         {:ok, _} <- set_avatar(user, nil),
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
    case File.cp(path, avatar_path(user, ext)) do
      :ok ->
        :ok
      _ ->
        {:error, error_changeset(user,
          "could not be uploaded")}
    end
  end

  defp remove_stored_upload(%User{avatar_file_ext: ext} = user) do
    case File.rm(avatar_path(user, ext)) do
      :ok ->
        :ok
      _ ->
        {:error, error_changeset(user,
          "could not be removed")}
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
