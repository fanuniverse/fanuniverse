defmodule Fanuniverse.Repo do
  use Ecto.Repo, otp_app: :fanuniverse
  use Pagination.Repo

  import Ecto.Query

  def reload(%{id: id, __struct__: schema}), do: get(schema, id)

  def reload!(%{id: id, __struct__: schema}), do: get!(schema, id)

  def count(queryable) do
    queryable
    |> exclude(:select)
    |> exclude(:preload)
    |> select([q], count(q.id))
    |> one()
  end
end
