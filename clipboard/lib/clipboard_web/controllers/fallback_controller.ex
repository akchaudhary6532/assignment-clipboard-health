defmodule ClipboardWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ClipboardWeb, :controller
  alias Clipboard.Helpers.ErrorMapper

  def call(conn, {:error, _message} = error) do
    ErrorMapper.format(conn, error)
  end

  def call(conn, {:ok, data}) do
    conn
    |> put_status(:ok)
    |> json(data)
  end

  def bad_request(conn, message) do
    conn
    |> put_status(400)
    |> json(%{message: message})
  end
end
