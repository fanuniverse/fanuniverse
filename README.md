# Fan Universe

## Prerequisites

* Docker
* [Docker Compose](https://docs.docker.com/compose/install/)
* [Yarn](https://yarnpkg.com/en/docs/install)
* [Elixir](https://elixir-lang.org/install.html) (1.4.4)

## Getting up and running

```bash
mix deps.get
cd assets
yarn install
cd ..
```

```bash
docker-compose up
mix ecto.create && mix ecto.migrate

# Either boot up the server (bound to localhost:4000)...
mix phx.server

# ...or run the test suite.
mix test

# (You shouldn't have both running at the same time.)
```
