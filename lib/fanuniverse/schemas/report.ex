defmodule Fanuniverse.Report do
  use Fanuniverse.Schema

  alias Fanuniverse.User
  alias Fanuniverse.Report
  alias Fanuniverse.Repo

  schema "reports" do
    belongs_to :creator, User
    belongs_to :resolver, User

    field :body, :string
    field :resolved, :boolean, default: false

    belongs_to :image, Fanuniverse.Image
    belongs_to :comment, Fanuniverse.Comment

    timestamps()
  end

  def resolve(%Report{} = report, %User{} = resolver) do
    report
    |> Repo.preload(:resolver)
    |> change(resolved: true)
    |> put_assoc(:resolver, resolver)
    |> Repo.update()
  end

  def unresolved do
    from r in Report,
    where: r.resolved == false,
    preload: [:creator, :image, :comment]
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:image_id, :comment_id, :body])
    |> cast_assoc(:creator)
    |> validate_required([:body])
    |> foreign_key_constraint(:image_id)
    |> foreign_key_constraint(:comment_id)
    |> check_constraint(:id, name: :belongs_to_integrity,
        message: "A report must belong to a single resource.")
  end

  def insert_for_duplicate_image(duplicate_id, original_id) do
    %Report{image_id: duplicate_id}
    |> changeset(%{body: "This image might be a duplicate of ##{original_id}."})
    |> Repo.insert()
  end
end
