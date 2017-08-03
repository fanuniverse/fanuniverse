defmodule Fanuniverse.ImageProcessingUpdateAction do
  @moduledoc """
  This action is executed by `Dispatcher.Vidalia` when it receives
  image metadata from Vidalia, the image processing service.
  """

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.ImageIndex
  alias Fanuniverse.ImageDuplicateDetectionJob
  alias Ecto.Changeset
  alias Elasticfusion.Document

  def perform!(id, width, height, phash, ext) do
    Image
    |> Repo.get!(id)
    |> Image.processed_changeset(
         %{width: width, height: height, phash: phash, ext: ext})
    |> Repo.update!
    |> Document.index(ImageIndex)

    ImageDuplicateDetectionJob.run(id)
  end
end
