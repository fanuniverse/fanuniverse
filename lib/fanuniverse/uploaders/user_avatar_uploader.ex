defmodule Fanuniverse.UserAvatarUploader do
  use Fanuniverse.Uploader

  alias Fanuniverse.Repo
  alias Fanuniverse.User

  @max_file_size 300 * 1024 # 300kB

  @allowed_content_types %{
    "image/png" => "png",
    "image/jpeg" => "jpg",
    "image/gif" => "gif"
  }

  def upload(%User{} = user, %Plug.Upload{} = upload) do
    status =
      with {:ok, ext} <- check_type(upload, @allowed_content_types),
            :ok       <- check_file_size(upload, @max_file_size),
            :ok       <- store_upload(user, upload, ext),
           {:ok, _}   <- set_avatar(user, ext),
        do: :ok

    case status do
      :ok -> :ok
      {:error, :unsupported_content_type} -> {:error, error_changeset(user,
        :avatar, "image is not recognized; supported formats are PNG, JPG, GIF")}
      {:error, :file_too_large} -> {:error, error_changeset(user,
        :avatar, "is too large; the file should be smaller than 300kB")}
      _ -> {:error, error_changeset(user,
        :avatar, "could not be uploaded")}
    end
  end

  def remove(%User{} = user) do
    status =
      with  :ok     <- remove_stored_upload(user),
           {:ok, _} <- set_avatar(user, nil),
        do: :ok

    case status do
      :ok -> :ok
      _ -> {:error, error_changeset(user, :avatar, "could not be removed")}
    end
  end

  defp avatar_path(%User{name: name}, ext) do
    avatar_root = Application.get_env(:fanuniverse, :avatar_fs_path)

    Path.join(avatar_root, name <> "." <> ext)
  end

  defp store_upload(user, %Plug.Upload{path: path}, ext),
    do: File.cp(path, avatar_path(user, ext))

  defp remove_stored_upload(%User{avatar_file_ext: ext} = user),
    do: File.rm(avatar_path(user, ext))

  defp set_avatar(user, ext),
    do: user
        |> Ecto.Changeset.change(%{avatar_file_ext: ext})
        |> Repo.update()

  defp error_changeset(user, field, message) do
    changeset =
      user |> User.changeset() |> Ecto.Changeset.add_error(field, message)

    %{changeset | action: :update}
  end
end
