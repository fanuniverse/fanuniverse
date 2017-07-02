defmodule Fanuniverse.Schema.Polymorphic do
  defmacro __using__(opts) do
    [
      quote do
        use Fanuniverse.Schema

        def query_for_resource(resource) do
          from c in __MODULE__, where: ^[resource_key_and_id(resource)]
        end
      end,

      for {resource_key, resource} <- opts[:resources] do
        resource_string_key = Atom.to_string(resource_key)

        quote do
          @doc """
          Extracts a tuple of `{resource_key_atom, resource_id}` (e.g. {:image_id, 1})
          from a given map/struct that
          a) has the resource_key as string or an atom (e.g. %{"image_id" => 1})
          b) belongs to the resource_struct type (e.g. %Image{id: 1})
          """
          def resource_key_and_id(%{unquote(resource_string_key) => id})
            when not is_nil(id), do: {unquote(resource_key), id}
          def resource_key_and_id(%{unquote(resource_key) => id})
            when not is_nil(id), do: {unquote(resource_key), id}
          def resource_key_and_id(%unquote(resource){id: id}),
            do: {unquote(resource_key), id}
        end
      end
    ]
  end
end
