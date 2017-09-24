defmodule Job do
  @moduledoc """
  A simple wrapper for background jobs that runs them
  synchronously in tests and offloads them to Toniq
  in other environments.
  """

  if Mix.env == :test do
    def run(worker, args \\ []), do: worker.perform(args)
  else
    def run(worker, args \\ []), do: Toniq.enqueue(worker, args)
  end
end
