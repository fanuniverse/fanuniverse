defmodule Fanuniverse.Web.ContentSecurityPolicy do
  alias Fanuniverse.Web.Endpoint

  import Application, only: [get_env: 2]
  import Plug.Conn, only: [put_resp_header: 3]

  @scheme (if get_env(:fanuniverse, Endpoint)[:url][:port] == 443,
    do: "https", else: "http")
  @host get_env(:fanuniverse, Endpoint)[:url][:host]
    |> String.trim_leading("www.")

  @client_url (@scheme <> "://client." <> @host)
  @static_url (@scheme <> "://static." <> @host)

  @csp_directives """
  block-all-mixed-content;
  frame-ancestors 'none';
  default-src 'self';
  connect-src 'self' #{@client_url};
  font-src 'self' #{@static_url} https://fonts.gstatic.com;
  img-src 'self' data: #{@static_url} #{@client_url} https://www.google-analytics.com;
  media-src 'self' #{@static_url};
  script-src #{@static_url} https://www.google-analytics.com;
  style-src 'self' #{@static_url} https://fonts.googleapis.com;
  """ |> String.replace("\n", " ")

  def init(opts),
    do: opts

  def call(conn, _opts),
    do: put_resp_header(conn, "Content-Security-Policy", @csp_directives)
end
