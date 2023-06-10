defmodule Clipboard.Helpers.Utils do
  def get_pagination_info(params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    size = Map.get(params, "size", "30") |> String.to_integer()

    if page < 1 or size > 1000 do
      {:error, "invalid page or size is too large"}
    else
      {:ok, page, size}
    end
  end

  def format_date_range(params) do
    start_unix = Map.get(params, "start") |> parse_integer()
    end_unix = Map.get(params, "end") |> parse_integer()

    {:ok, from_unix_to_dt(start_unix), from_unix_to_dt(end_unix)}
  end

  def from_unix_to_dt(nil), do: nil

  def from_unix_to_dt(unix_timestamp) do
    datetime_utc = DateTime.from_unix!(unix_timestamp)

    # Convert UTC DateTime to local naive DateTime
    DateTime.to_naive(datetime_utc)
  end

  def parse_integer(nil), do: nil
  def parse_integer(integer)  when is_integer(integer), do: integer
  def parse_integer(string) do
    case Integer.parse(string) do
      :error -> :error
      {int, ""} -> int
      _ -> :error
    end
  end
end
