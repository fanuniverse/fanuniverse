defmodule Fanuniverse.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fanuniverse,
      version: git_tag_version(),
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Fanuniverse.Application, []},
      extra_applications: [
        :logger
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp git_tag_version do
    {version, 0} = System.cmd("git", ~w(describe --abbrev=0 --tags))
    String.trim(version)
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, "~> 0.13.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_slime, "~> 0.9"},
      {:slime, "~> 1.1", override: true},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0"},
      {:redbird, "~> 0.4.0"},
      {:toniq, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:elastix, "~> 0.4.0"},
      {:elasticfusion, github: "fanuniverse/elasticfusion", tag: "1.1.0"},
      {:calendar, "~> 0.17.2"},
      {:paper_trail, "~> 0.7.5"},
      {:download, github: "little-bobby-tables/download", branch: "fix-process-communication"},
      {:canada, "~> 1.0.2"},
      {:inflex, "~> 1.8"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:ex_machina, "~> 2.0", only: :test},
      {:distillery, "~> 1.4", runtime: false}
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "ecto.migrate": ["ecto.migrate", "ecto.dump"],
     "ecto.rollback": ["ecto.rollback", "ecto.dump"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
