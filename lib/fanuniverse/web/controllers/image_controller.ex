defmodule Fanuniverse.Web.ImageController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Image
  alias Fanuniverse.ImageUploadAction, as: ImageUpload

  def index(conn, _params) do
    images = Repo.all Image
    render conn, "index.html", images: images
  end

  def show(conn, %{"id" => id}) do
    image = Repo.get! Image, id
    render conn, "show.html", image: image
  end

  def new(conn, _params) do
    changeset = Image.changeset(%Image{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"image" => image_params}) do
    case ImageUpload.perform(image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image created successfully.")
        |> redirect(to: image_path(conn, :show, image))
      {:error, changeset, image_cache, cache_url} ->
        render conn, "new.html",
          changeset: changeset, image_cache: image_cache,
          image_preview_url: cache_url
    end
  end
end
