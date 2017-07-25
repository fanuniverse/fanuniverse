# Fan Universe

## Prerequisites

Running Linux is strongly recommended. You'll likely have to jump through hoops
to set the environment up elsewhere.

#### Docker

* [Docker CE](https://docker.com/community-edition#/download)
* [Docker Compose](https://docs.docker.com/compose/install/)

Run `docker-compose pull` in the project root to fetch all dependencies.

#### Development tools

* [asdf](https://github.com/asdf-vm/asdf)
* [asdf-erlang](https://github.com/asdf-vm/asdf-erlang)
* [asdf-elixir](https://github.com/asdf-vm/asdf-elixir)
* [asdf-nodejs](https://github.com/asdf-vm/asdf-nodejs)

Please read the documentation for each plugin; they may require additional
dependencies to be installed.

After getting asdf and plugins, run `asdf install` in the project root.

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
( cd assets && npm install )

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
