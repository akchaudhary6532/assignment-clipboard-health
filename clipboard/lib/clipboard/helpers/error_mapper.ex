defmodule Clipboard.Helpers.ErrorMapper do
  def format(conn, {:error, :worker}), do: format(conn, {:error, "Worker is invalid or inactive"})
  def format(conn, {:error, :facility}), do: format(conn, {:error, "Facility is invalid or inactive"})
  def format(conn, {:error, :date_range_error}), do: format(conn, {:error, "Invalid date range"})

  def format(conn, {:error, message}, error_code \\ 422) do
    conn
    |> Plug.Conn.put_status(error_code)
    |> Phoenix.Controller.json(%{message: message})
  end
end
