defmodule Fanuniverse.Repo do
  use Ecto.Repo, otp_app: :fanuniverse

  import Ecto.Query
  import Enum, only: [map: 2, find: 2, reject: 2]
  import Fanuniverse.Utils, only: [parse_integer: 2]

  def get_by_ids_sorted(query, ids) do
    records = all(from(r in query, where: r.id in ^ids))

    ids
    |> map(fn(id) ->
         find(records, &(&1.id == parse_integer(id, nil)))
       end)
    |> reject(&is_nil/1)
  end
end
