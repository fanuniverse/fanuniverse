defmodule Fanuniverse.FactoryMod do
  @moduledoc """
  Use this module in cases that work with ExMachina factories.
  """

  defmacro __using__(_) do
    quote do
      import Fanuniverse.Factory

      alias Fanuniverse.User
      alias Fanuniverse.Repo

      def test_user do
        case Repo.get_by(User, name: "Peridot") do
          nil ->
            insert_user(%{name: "Peridot",
              email: "technician@homeworld", password: "password"})
          user ->
            %{user | password: "password"}
        end
      end

      def insert_user(fields) do
        fields = Map.put(fields, :password_confirmation, fields[:password])
        %User{} |> User.registration_changeset(fields) |> Repo.insert!
      end
    end
  end
end
