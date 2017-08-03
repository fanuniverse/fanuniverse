defmodule Dispatcher.Sapphire do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def update_tags(add, remove) do
    GenServer.cast(__MODULE__, {:update, add, remove})
  end

  # Internal

  def handle_cast({:update, add, remove}, state) do
    url_root = Application.get_env(:fanuniverse, :services)[:sapphire_url_root]

    HTTPoison.post("#{url_root}/update", {:form,
      [add: Poison.encode!(add), remove: Poison.encode!(remove)]})

    {:noreply, state}
  end
end
