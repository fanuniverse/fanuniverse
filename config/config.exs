# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :fanuniverse,
  ecto_repos: [Fanuniverse.Repo],
  image_url_root: "http://static.lvh.me/images",
  avatar_url_root: "http://static.lvh.me/avatars",
  cache_url_root: "http://static.lvh.me/upload",
  asset_url_root: "http://static.lvh.me/assets",
  avatar_fs_path: "priv/avatars",
  image_fs_path: "priv/images",
  cache_fs_path: "priv/cache"

config :fanuniverse, :services,
  sapphire_url_root: "localhost:3030",
  vidalia_url_root: "localhost:3040"

config :fanuniverse, Fanuniverse.Web.Endpoint,
  url: [host: "www.lvh.me"],
  secret_key_base: "replace-this-string-with-an-actual-preferrably-not-hardcoded-key", # FIXME:
  render_errors: [view: Fanuniverse.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Fanuniverse.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

config :redbird,
  key_namespace: "s_"

config :comeonin,
  :bcrypt_log_rounds, 14

config :elasticfusion,
  endpoint: "http://localhost:9200"

config :paper_trail,
  repo: Fanuniverse.Repo,
  originator: [name: :user, model: Fanuniverse.User]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
