use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fanuniverse, Fanuniverse.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :fanuniverse, Fanuniverse.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "fanuniverse",
  password: "fanuniverse",
  database: "fanuniverse_test",
  hostname: "localhost",
  port: 5434,
  pool: Ecto.Adapters.SQL.Sandbox

config :comeonin, :bcrypt_log_rounds, 4
