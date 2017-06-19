defmodule Fanuniverse.ImageProcessingUpdateAction do
  @moduledoc """
  This action is executed by `Dispatcher.Image` when it receives
  image metadata from Vidalia, the image processing service.
  """

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Ecto.Changeset

  def perform!(id, width, height, phash) do
    Image
    |> Repo.get!(id)
    |> Image.processed_changeset(
         %{width: width, height: height, phash: phash})
    |> Repo.update!
  end
end
