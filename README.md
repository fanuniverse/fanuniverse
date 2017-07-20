# Fan Universe

## Prerequisites

* Docker
* [Docker Compose](https://docs.docker.com/compose/install/)
* [Yarn](https://yarnpkg.com/en/docs/install)
* [Elixir](https://elixir-lang.org/install.html) (1.4.4)

## Getting up and running

#### Start containerized services:

```bash
docker-compose up
```

#### Prepare your environment (you only need to this once):

* Increase the `vm_max_map_count` kernel setting to at least `262144`
(refer to [this article][1] for more information)

[1]:https://www.elastic.co/guide/en/elasticsearch/reference/5.5/vm-max-map-count.html

```bash
# Install dependencies
mix deps.get
( cd assets && yarn install )

# Set up the database
mix ecto.create && mix ecto.migrate

# Create Elasticsearch indexes
mix run -e "Fanuniverse.ImageIndex \
|> Elasticfusion.IndexAPI.create_index() \
|> IO.inspect()"
```

#### Finally:
```bash
# Either boot up the server (bound to localhost:4000)...
mix phx.server

# ...or run the test suite.
mix test

# You should _not_ have both running at the same time!
```
