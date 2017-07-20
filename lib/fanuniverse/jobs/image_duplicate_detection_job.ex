defmodule Fanuniverse.ImageDuplicateDetectionJob do
  @duplicate_threshold 0.76

  import Ecto.Query

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.Report

  def run(image_id) do
    image = Repo.get!(Image, image_id)
    image_id = Fanuniverse.Utils.parse_integer(image_id, nil)

    duplicate_ids = Repo.all(
      from i in Image,
      select: i.id,
      where: i.id != ^image_id and fragment(
        "hamming_text(phash, ?) > ?", ^image.phash, @duplicate_threshold))

    for duplicate_id <- duplicate_ids do
      Report.insert_for_duplicate_image(image_id, duplicate_id)
    end
  end
end
