defmodule ClipboardWeb.ShiftController do
  use ClipboardWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Clipboard.Context.AvailableShifts
  alias Clipboard.Helpers.Utils
  alias ClipboardWeb.FallbackController

  alias ClipboardWeb.Spec.ErrorMessage
  alias ClipboardWeb.Spec.Shift.AvailableResponse

  # handle error and send generic result
  action_fallback ClipboardWeb.FallbackController

  operation :get,
  summary: "Get all available shifts for a given worker",
  parameters: [
    worker_id: [in: :path, description: "Worker ID", type: :integer, example: 1001, required: true],
    start: [in: :query, description: "Start date range in unix", type: :integer, example: 1685208258, required: false],
    end: [in: :query, description: "End date range in unix", type: :integer, example: 1685208258, required: false]
  ],
  responses: [
    bad_request: {"Invalid worker_id or facility_id", "application/json", ErrorMessage},
    unprocessable_entity: {"worker_id or facility_id doesn't exisit or disabled or invalid date range", "application/json", ErrorMessage},
    ok: {"User response", "application/json", AvailableResponse}
  ]

  def available(conn, params = %{"worker_id" => worker_id}) do
    with {:ok, page, size} <- Utils.get_pagination_info(params),
         {:ok, start_dt, end_dt} <- Utils.format_date_range(params),
         {:worker_id, worker_id} when is_integer(worker_id) <- {:worker_id, Utils.parse_integer(worker_id)},
         {:facility_id, facility_id} when is_integer(facility_id) or is_nil(facility_id) <- {:facility_id, parse_facility_id(params["facility_id"])},
         data when is_map(data) <- AvailableShifts.get_all_available_shifts(worker_id, page, size, start_dt, end_dt, facility_id) do
      conn
      |> put_status(:ok)
      |> render("list.json", %{data: data})
    else
      {:worker_id, _} -> FallbackController.bad_request(conn, "Invalid worker_id")
      {:facility_id, _} -> FallbackController.bad_request(conn, "Invalid facility_id")
      error -> error
    end
  end

  defp parse_facility_id(string) do
    if is_nil(string),
      do: nil,
      else: Utils.parse_integer(string)
  end
end
