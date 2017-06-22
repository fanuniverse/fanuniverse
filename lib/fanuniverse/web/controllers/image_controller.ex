defmodule Fanuniverse.Web.ImageController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Image
  alias Fanuniverse.ImageUploadAction, as: ImageUpload

  def index(conn, params) do
    images = find_images(params)
    render conn, "index.html", images: images
  end

  def show(conn, %{"id" => id}) do
    image = Repo.get!(Image, id)
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

  # TODO: generalize & move to a separate module
  defp find_images(params) do
    page = Fanuniverse.Utils.parse_integer(params["page"], 0)

    per_page = Fanuniverse.Utils.parse_integer(params["per_page"], 10)
    per_page = if per_page > 20, do: 20, else: per_page

    query = if is_binary(params["q"]) && params["q"] != "" do
      Elasticfusion.Search.Builder.parse_search_string(
        params["q"], Fanuniverse.ImageIndex)
    else
      %{}
    end
    query =
      query
      |> Elasticfusion.Search.Builder.add_sort("id", :desc)
      |> Elasticfusion.Search.Builder.paginate(page, per_page)
      |> Elasticfusion.Search.Builder.add_filter_clause(%{term: %{visible: true}})

    {:ok, ids} = Elasticfusion.Search.find_ids(query, Fanuniverse.ImageIndex)

    Repo.all(from(i in Image, where: i.id in ^ids))
  end
end
