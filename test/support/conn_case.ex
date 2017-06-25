defmodule Fanuniverse.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      use Fanuniverse.FactoryMod

      alias Fanuniverse.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Fanuniverse.Web.Router.Helpers

      # The default endpoint for testing
      @endpoint Fanuniverse.Web.Endpoint

      def test_user_session do
        build_conn() |> post("/sign_in", %{"session" => %{
          "email" => test_user().email, "password" => test_user().password
        }})
      end

      def refresh_index(elasticfusion_index),
        do: Elastix.Index.refresh("localhost:9200", elasticfusion_index.index_name())
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fanuniverse.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Fanuniverse.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
