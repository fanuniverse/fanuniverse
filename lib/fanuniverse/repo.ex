defmodule Fanuniverse.Repo do
  use Ecto.Repo, otp_app: :fanuniverse
  use Pagination.Repo
end
