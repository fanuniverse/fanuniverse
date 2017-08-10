defmodule Dispatcher.Vidalia do
  @moduledoc """
  This dispatcher interacts with Vidalia, the image processing service.
  Refer to https://github.com/little-bobby-tables/vidalia for more information.
  """

  use GenServer
  use AMQP

  alias Fanuniverse.Image

  @processing_queue "image.process"
  @processed_queue "image.processed"

  def start_link(connection) do
    GenServer.start_link(__MODULE__, connection, name: __MODULE__)
  end

  def request_processing(id, cached_file) do
    GenServer.cast(__MODULE__, {:enqueue, id, cached_file})
  end

  # Internal

  def init(connection) do
    {:ok, channel} = Channel.open(connection)

    channel |> Queue.declare(@processing_queue, durable: true)
    channel |> Queue.declare(@processed_queue, durable: true)

    {:ok, _tag} = Basic.consume(channel, @processed_queue)

    {:ok, {channel, nil}}
  end

  # Puts image into the `@processing_queue`.
  def handle_cast({:enqueue, id, file}, {channel, _} = state) do
    payload = Poison.encode!(
      %{"id" => to_string(id), "file" => to_string(file)})

    Basic.publish(channel, "", @processing_queue, payload)

    {:noreply, state}
  end

  # See handle_info/2 clause for `:basic_deliver`.
  if Mix.env == :test do
    def handle_cast({:set_callback, fun}, {channel, _}) when is_function(fun, 1) do
      {:noreply, {channel, fun}}
    end
  end

  # Consumes image metadata from the `@processed_queue`.
  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, {channel, callback}) do
    spawn fn ->
      {:ok, _} =
        payload
        |> Poison.decode!()
        |> Image.update_after_processing()

      if Code.ensure_loaded?(Mix) && Mix.env == :test do
        %{"id" => id} = Poison.decode!(payload)
        callback.(id)
      end
    end

    Basic.ack(channel, tag)

    {:noreply, {channel, callback}}
  end

  # Sent by the broker after registering this process as a consumer.
  def handle_info({:basic_consume_ok, _}, state), do: {:noreply, state}

  # Sent by the broker after Basic.cancel/3.
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  # Sent by the broker when the consumer is unexpectedly cancelled.
  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
end
