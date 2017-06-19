use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
config :fanuniverse, Fanuniverse.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [env: ["sh", "gulp-watch", cd: Path.expand("../bin", __DIR__)]]

# Watch static and templates for browser reloading.
config :fanuniverse, Fanuniverse.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/fanuniverse/web/views/.*(ex)$},
      ~r{lib/fanuniverse/web/templates/.*(eex|slim|slime)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :fanuniverse, Fanuniverse.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "fanuniverse",
  password: "fanuniverse",
  database: "fanuniverse_dev",
  hostname: "localhost",
  port: 5434,
  pool_size: 10
