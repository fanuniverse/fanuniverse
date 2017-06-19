defmodule Fanuniverse.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :fanuniverse

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :fanuniverse, gzip: false,
    only: ~w(app.css app.js fonts uploads)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

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
