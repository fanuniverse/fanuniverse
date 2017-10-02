defmodule Fanuniverse.Web.ImageController do
  use Fanuniverse.Web, :controller

  plug EnsureAuthenticated when action in [:new, :edit, :create, :update]
  plug :put_layout, false when action in [:more]

  alias Fanuniverse.Image

  def index(conn, params) do
    {:ok, pagination, images} =
      Repo.paginate_es(
        image_search_query(params, user(conn)),
        Fanuniverse.ImageIndex, Image, params,
        [default_per_page: 10, max_per_page: 50])

    render conn, "index.html", images: images, pagination: pagination
  end

  def show(conn, %{"id" => id}) do
    image = Image |> Repo.get!(id) |> Repo.preload(:suggested_by)
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
    case Image.insert(image_params, user(conn)) do
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

    case Image.update(image_params, image, user(conn)) do
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
    query = image_search_query(params, user(conn))

    target = case peeker_fun.(current, query, Fanuniverse.ImageIndex) do
      {:ok, target} when is_binary(target) -> target
      _ -> current
    end

    redirect conn, to: image_path(conn, :show, target,
      Map.take(params, ["q", "sort"]))
  end

  def more(conn, %{"id" => id}) do
    {:ok, ids, _} =
      id
      |> image_more_query(count: 40)
      |> Elasticfusion.Search.find_ids(Fanuniverse.ImageIndex)
    images =
      Repo.get_by_ids_sorted(Image, ids)
    link_params =
      %{"q" => "mlt: #{id}"}

    render conn, "more.html", images: images, link_params: link_params
  end

  def history(conn, %{"id" => id}) do
    image = Repo.get!(Image, id)
    render conn, "history.html", image: image
  end

  # TODO: generalize & move to a separate module

  defp image_search_query(params, context) do
    import Elasticfusion.Search.Builder
    import Fanuniverse.Web.ImageView, only: [image_sort_field_direction: 1]

    {sort_field, sort_direction} = image_sort_field_direction(params)

    (if is_binary(params["q"]) && params["q"] != "" do
      parse_search_string(params["q"], Fanuniverse.ImageIndex, context)
    else
      %{}
    end)
    |> add_sort(sort_field, sort_direction)
    |> add_sort(:id, :desc)
    |> add_filter_clause(%{term: %{visible: true}})
  end

  defp image_more_query(id, [count: count]) do
    import Elasticfusion.Search.Builder

    id
    |> more_like_this(Fanuniverse.ImageIndex)
    |> add_sort(:stars, :desc)
    |> add_sort(:id, :desc)
    |> paginate(1, count)
  end
end
