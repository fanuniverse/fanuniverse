defmodule Fanuniverse.Web.Router do
  use Fanuniverse.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Auth.Plug.LoadAunthenticatedUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Fanuniverse.Web do
    pipe_through :browser

    get "/", ImageController, :index

    resources "/images", ImageController,
      only: [:show, :new, :create, :edit, :update]
    get "/images/:id/next", ImageController, :next
    get "/images/:id/previous", ImageController, :previous

    resources "/comments", CommentController,
      only: [:index, :create]

    post "/stars/toggle", StarController, :toggle

    get "/sign_in", UserSessionController, :new
    post "/sign_in", UserSessionController, :create
    delete "/sign_out", UserSessionController, :delete

    resources "/profiles", UserProfileController, param: "name",
      only: [:show]
    resources "/profile", UserProfileController, singleton: true,
      only: [:edit, :update]

    get "/sign_up", UserController, :new
    post "/sign_up", UserController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", Fanuniverse do
  #   pipe_through :api
  # end
end
