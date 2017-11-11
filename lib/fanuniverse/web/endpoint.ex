defmodule Fanuniverse.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :fanuniverse

  if Mix.env == :dev || Mix.env == :test do
    plug Plug.Static,
      at: "/", from: :fanuniverse, only: ~w(no-avatar.svg)
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    length: 30 * 1024 * 1024

  plug Plug.MethodOverride
  plug Plug.Head

  # Use server-side sessions to simplify the authentication
  # mechanism. Do _not_ change this to a client-side (cookie)
  # storage without understanding how the auth works first!
  plug Plug.Session,
    store: :redis,
    key: "_session",
    expiration_in_seconds: 60 * 60 * 24 * 14 # 14 days

  plug Fanuniverse.Web.Router
end
