defmodule Fanuniverse.Web.ImageController do
  use Fanuniverse.Web, :controller

  alias Fanuniverse.Image
  alias Fanuniverse.ImageUploadAction, as: ImageUpload

  def index(conn, params) do
    {:ok, pagination, images} = find_images(params)
    render conn, "index.html", images: images, pagination: pagination
  end

  def show(conn, %{"id" => id}) do
    image = Repo.get!(Image, id)
    render conn, "show.html", image: image
  end

  def new(conn, _params) do
    changeset = Image.changeset(%Image{})
    render conn, "new.html", changeset: changeset
  end

  def edit(conn, %{"id" => id}) do
    image = Repo.get!(Image, id)
    changeset = Image.changeset(image)
    render conn, "edit.html", image: image, changeset: changeset
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

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Repo.get!(Image, id)

    case Image.update(image, user(conn), image_params) do
      {:ok, _} ->
        redirect conn, to: image_path(conn, :show, image)
      {:error, error_changeset} ->
        render conn, "edit.html", image: image, changeset: error_changeset
    end
  end

  def next(conn, params),
    do: navigate(conn, params, &Elasticfusion.Peek.next_id/3)
  def previous(conn, params),
    do: navigate(conn, params, &Elasticfusion.Peek.previous_id/3)
  def navigate(conn, %{"id" => id} = params, peeker_fun) do
    current = Repo.get!(Image, id)
    query = image_search_query(params)

    target = case peeker_fun.(current, query, Fanuniverse.ImageIndex) do
      {:ok, target} when is_binary(target) -> target
      _ -> current
    end

    redirect conn, to: image_path(conn, :show, target,
      Map.take(params, ["q", "sort"]))
  end

  defp find_images(params) do
    Repo.paginate_es(
      image_search_query(params),
      Fanuniverse.ImageIndex,
      Image,
      params,
      [default_per_page: 10, max_per_page: 50]
    )
  end

  # TODO: generalize & move to a separate module

  alias Elasticfusion.Search.Builder

  defp image_search_query(params) do
    query = if is_binary(params["q"]) && params["q"] != "" do
      Builder.parse_search_string(params["q"], Fanuniverse.ImageIndex)
    else
      %{}
    end

    {sort_field, sort_direction} =
      Fanuniverse.Web.ImageView.image_sort_field_direction(params)

    query
    |> Builder.add_sort(sort_field, sort_direction)
    |> Builder.add_sort("id", :desc)
    |> Builder.add_filter_clause(%{term: %{visible: true}})
  end
end
