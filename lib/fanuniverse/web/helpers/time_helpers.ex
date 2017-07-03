defmodule Fanuniverse.Web.TimeHelpers do
  import Phoenix.HTML.Tag
  import Calendar.NaiveDateTime, only: [gregorian_seconds: 1]

  def time_tag(%NaiveDateTime{} = date) do
    pretty_utc_date =
      Calendar.Strftime.strftime!(date, "%B %d, %Y %H:%M UTC")
    iso8601_date_with_tz =
      Calendar.Strftime.strftime!(date, "%Y-%m-%dT%H:%M:%SZ")

    content_tag :time, pretty_utc_date, datetime: iso8601_date_with_tz
  end

  # Source: https://gist.github.com/h00s/b863579ec9c7b8c65311e6862298b7a0
  def time_ago_in_words(%NaiveDateTime{} = date) do
    seconds =
      gregorian_seconds(NaiveDateTime.utc_now()) - gregorian_seconds(date)
    minutes =
      round(seconds / 60)

    case minutes do
      minutes when minutes in 0..1 ->
        case seconds do
          seconds when seconds in 0..4 ->
            "less than 5 seconds"
          seconds when seconds in 5..9 ->
            "less than 10 seconds"
          seconds when seconds in 10..19 ->
            "less than 20 seconds"
          seconds when seconds in 20..39 ->
            "half a minute"
          seconds when seconds in 40..59 ->
            "less than 1 minute"
          _ ->
            "1 minute"
        end
      minutes when minutes in 2..44 ->
        "#{minutes} minutes"
      minutes when minutes in 45..89 ->
        "about 1 hour"
      minutes when minutes in 90..1439 ->
        "about #{round(minutes / 60)} hours"
      minutes when minutes in 1440..2519 ->
        "1 day"
      minutes when minutes in 2520..43199 ->
        "#{round(minutes / 1440)} days"
      minutes when minutes in 43200..86399 ->
        "about 1 month"
      minutes when minutes in 86400..525599 ->
        "#{round(minutes / 43200)} months"
      minutes when minutes in 525600..1051199 ->
        "1 year"
      _ ->
        "#{round(minutes / 525600)} years"
    end
  end
end
