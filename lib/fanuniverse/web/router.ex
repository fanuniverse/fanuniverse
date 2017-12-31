defmodule Fanuniverse.Web.Router.StaticPages do
  pages =
    Enum.map(File.ls!("lib/fanuniverse/web/templates/static_page"), fn(template) ->
      template |> String.split(".") |> List.first() |> String.to_atom()
    end)

  defmacro list, do: unquote(pages)
end

defmodule Fanuniverse.Web.Router do
  use Fanuniverse.Web, :router

  require Fanuniverse.Web.Router.StaticPages, as: StaticPages

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Auth.Plug.LoadAunthenticatedUser
    plug Fanuniverse.Web.CSPPlug
    plug Fanuniverse.Web.IntroSplashPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Fanuniverse.Web do
    pipe_through :browser

    scope "/admin", Admin, as: :admin do
      get "/dashboard", DashboardController, :index

      get "/images/merge", ImageController, :merge
      get "/images/commit_merge", ImageController, :commit_merge

      get "/reports", ReportController, :index
      post "/reports/:id/resolve", ReportController, :resolve
    end

    get "/", ImageController, :index

    resources "/images", ImageController,
      only: [:show, :new, :create, :edit, :update]
    get "/images/:id/next", ImageController, :next
    get "/images/:id/previous", ImageController, :previous
    get "/images/:id/history", ImageController, :history
    get "/images/:id/mlt", ImageController, :mlt

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

    for page <- StaticPages.list() do
      get "/#{page}", StaticPageController, page
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Fanuniverse do
  #   pipe_through :api
  # end
end
