defmodule Fanuniverse.Repo do
  use Ecto.Repo, otp_app: :fanuniverse
  use Pagination.Repo

  def reload(%{id: id, __struct__: schema}), do: get(schema, id)

  def reload!(%{id: id, __struct__: schema}), do: get!(schema, id)
end
