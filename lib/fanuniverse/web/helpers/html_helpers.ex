defmodule Fanuniverse.Web.HTMLHelpers do
  import Phoenix.HTML.Tag

  def time_tag(%NaiveDateTime{} = date) do
    pretty_utc_date =
      Calendar.Strftime.strftime!(date, "%B %d, %Y %H:%M UTC")
    iso8601_date_with_tz =
      Calendar.Strftime.strftime!(date, "%Y-%m-%dT%H:%M:%SZ")

    content_tag :time, pretty_utc_date, datetime: iso8601_date_with_tz
  end
end
