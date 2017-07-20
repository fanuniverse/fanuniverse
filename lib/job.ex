defmodule Job do
  @moduledoc """
  A half-baked wrapper for background jobs that runs them synchronously in tests
  and asynchronously in other environments.

  TODO FIXME: Add configurable delay and backoff (see gen_retry),
  define public interface for jobs (`__using__` or `@behaviour`).
  """

  if Mix.env == :test do
    def perform(fun) when is_function(fun, 0), do: fun.()
  else
    def perform(fun) when is_function(fun, 0), do: Task.start(fun)
  end
end
