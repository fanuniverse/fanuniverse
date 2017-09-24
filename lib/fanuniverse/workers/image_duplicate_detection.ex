defmodule Fanuniverse.Workers.ImageDuplicateDetection do
  # The queries we issue can be rather expensive,
  # it's better to run only few workers in parallel.
  use Toniq.Worker, max_concurrency: 2

  @duplicate_threshold 0.76

  import Ecto.Query

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.Report

  def perform(id: image_id) do
    image = Repo.get!(Image, image_id)
    image_id = Fanuniverse.Utils.parse_integer(image_id, nil)

    duplicate_ids = Repo.all(
      from i in Image,
      select: i.id,
      where: i.id != ^image_id and fragment(
        "hamming_text(hash, ?) > ?", ^image.hash, @duplicate_threshold))

    for duplicate_id <- duplicate_ids do
      {:ok, _} = Report.insert_for_duplicate_image(image_id, duplicate_id)
    end
  end
end
