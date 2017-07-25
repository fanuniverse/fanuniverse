defmodule Fanuniverse.Web.LayoutView do
  use Fanuniverse.Web, :view

  @main_title "Fan Universe"
  @app_version Mix.Project.config[:version]

  if Mix.env == :prod do
    @asset_manifest ("priv/static/manifest.json" |> File.read!() |> Poison.decode!())

    def precompiled_asset_url(asset_name) do
      root = Application.get_env(:fanuniverse, :asset_url_root)
      root <> "/" <> @asset_manifest[asset]
    end
  else
    def precompiled_asset_url(asset_name) do
      root = Application.get_env(:fanuniverse, :asset_url_root)
      root <> "/" <> asset_name
    end
  end

  def github_url,
    do: "https://github.com/fanuniverse/fanuniverse/tree/#{@app_version}"

  def page_title(conn, assigns) do
    custom_title = render_existing view_module(conn), "title",
      assigns_with_action(conn, assigns)

    if custom_title do
      custom_title <> " ∙ " <> @main_title
    else
      @main_title
    end
  end

  def layout_class(conn, assigns) do
    custom_type = render_existing view_module(conn), "layout",
      assigns_with_action(conn, assigns)

    case custom_type do
      :wide -> "layout--wide"
      :medium -> "layout--medium"
      :custom -> "layout--custom"
      _ -> "layout--narrow"
    end
  end

  defp assigns_with_action(conn, assigns),
    do: Map.put(assigns, :action_name, action_name(conn))
end
