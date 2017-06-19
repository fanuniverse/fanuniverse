defmodule Dispatcher.Supervisor do
  @moduledoc """
  Dispatchers communicate with external services over AMQP.

  This a subtree of the `Fanuniverse.Application` supervisor.
  """

  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, connection} =
      AMQP.Connection.open("amqp://guest:guest@localhost:5672")

    Logger.info("Established AMQP connection; initializing child dispatchers")

    children = [
      worker(Dispatcher.Image, [connection])
    ]

    supervise(children, [strategy: :one_for_one])
  end
end
