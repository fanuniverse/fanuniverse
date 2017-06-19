defmodule Auth.Helpers do
  @moduledoc """
  Import this module in controllers and views to access
  convenience functions for retrieving user from the conn struct.
  """

  def user(conn), do: conn.assigns[:user]

  def user_signed_in?(conn), do: !!conn.assigns[:user]
end
