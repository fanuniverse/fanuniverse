defmodule Fanuniverse.Web.IntroSplashPlug do
  @moduledoc """
  Sets `:display_splash` assign to `true` when the user
  a) is signed out,
  b) hasn't seen the intro page yet,
  c) has seen the splash less than four times.

  This plug needs to be run _after_ `Auth.Plug.LoadAunthenticatedUser`.
  """

  import Plug.Conn, only: [get_session: 2, put_session: 3, assign: 3]
  import Auth.Helpers, only: [user_signed_in?: 1]
  import Fanuniverse.Utils, only: [parse_integer: 2]

  @session_key "splash_displays"
  @assigns_key :display_splash
  @max_displays 4

  def init(opts), do: opts

  def call(conn, _opts) do
    if user_signed_in?(conn) do
      conn
    else
      splash_displays = conn |> get_session(@session_key) |> parse_integer(0)

      set_splash(conn, splash_displays)
    end
  end

  def set_splash(conn, displays) when displays >= @max_displays,
    do: put_session(conn, @session_key, @max_displays)
  def set_splash(%{path_info: ["intro" | _]} = conn, _displays),
    do: put_session(conn, @session_key, @max_displays)
  def set_splash(conn, displays),
    do: conn
        |> assign(@assigns_key, true)
        |> put_session(@session_key, displays + 1)
end
