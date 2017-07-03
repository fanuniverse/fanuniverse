defmodule Fanuniverse.StarToggleAction do
  alias Fanuniverse.Repo
  alias Fanuniverse.User
  alias Fanuniverse.Star

  import Ecto.Adapters.SQL, only: [query: 3]

  def perform(params, %User{id: user_id}) do
    {resource_key, resource_id} =
      Star.resource_key_and_id(params)

    # See priv/repo/functions/star_toggle.sql
    toggle_response = query(Repo,
      "SELECT * FROM star_toggle($1, $2, $3)",
      [user_id, to_string(resource_key), resource_id])

    case toggle_response do
      {:ok, %{rows: [[status, new_stars_count]]}} ->
        Job.perform fn ->
          # FIXME: schemas should have indexes associated with them somehow;
          # this way, we'll be able to easily determine if they need reindexing.
          if resource_key == :image_id do
            image = Repo.get!(Fanuniverse.Image, resource_id)
            :ok = Elasticfusion.Document.index(image, Fanuniverse.ImageIndex)
          end
        end

        {:ok, status, new_stars_count}
      {:error, _} = error ->
        error
    end
  end
end
