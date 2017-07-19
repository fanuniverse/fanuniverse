defmodule Auth.Authorization do
  @moduledoc """
  Controller functions for authorizing resources using the Canada
  library (see *lib/fanuniverse/abilities.ex*).
  """

  import Auth.Helpers, only: [user: 1, user_signed_in?: 1]
  import Canada.Can, only: [can?: 3]
  import Phoenix.Controller, only: [redirect: 2]

  @doc """
  Returns :ok if current user is authorized to perform `action` on `resource`,
  otherwise redirects to:
  * "/" (if user is authenticated)
  * "/sign_up" (otherwise)

  Example usage:

  ```
  def action(conn, params) do
    resource = Repo.get!(Resource, id)
    with :ok <- authorize(conn, :action, resource) do
      render ...
    end
  end
  ```
  """
  def authorize(conn, action, resource) do
    cond do
      user_signed_in?(conn) && can?(user(conn), action, resource) ->
        :ok
      user_signed_in?(conn) ->
        redirect(conn, to: "/")
      :otherwise ->
        redirect(conn, to: "/sign_up")
    end
  end
end
