defmodule ClipboardWeb.ShiftControllerTest do
  @moduledoc """
  Contains functional level test only, all logical test are in context test file
  """
  use ClipboardWeb.ConnCase

  # alias Clipboard.Test.Context.AvailableShifts
  alias Clipboard.Support.Factory

  @shift_data ~w(id start end facility_id)a

  describe "GET /shifts/:worker_id/available" do
    setup config do
      shift = Factory.insert(:shift)
      worker = Clipboard.Test.Context.AvailableShifts.get_worker_with_valid_document(shift)
      Map.merge(%{shift: shift, worker: worker}, config)
    end

    test "when worker_id is invalid", %{conn: conn} do
      ## given

      ## when
      response = get(conn, Routes.shift_path(conn, :available, "nil")) |> json_response(400)

      ## then
      assert response == %{"message" => "Invalid worker_id"}
    end

    test "when successful data", %{conn: conn, worker: worker, shift: shift} do
      ## given

      ## when

      %{"data" => data_list, "next" => -1} = get(conn, Routes.shift_path(conn, :available, worker.id)) |> json_response(200)

      ## then
      assert length(data_list) == 1
      assert hd(data_list)["id"] == shift.id
    end

    test "when facility_id is given and not found", %{conn: conn, worker: worker, shift: shift} do
      ## given

      ## when
      ## then
      assert %{"message" => "Facility is invalid or inactive"} ==
               get(conn, Routes.shift_path(conn, :available, worker.id), %{facility_id: -100}) |> json_response(422)
    end

    test "when date_range is given", %{conn: conn, worker: worker, shift: shift} do
      ## given

      ## when
      timestamp = naive_to_unix(shift.start)
      ## then
      %{"data" => [data], "next" => -1} = get(conn, Routes.shift_path(conn, :available, worker.id), %{start: timestamp}) |> json_response(200)
      assert data["id"] == shift.id
    end
  end

  def naive_to_unix(dt) do
    {:ok, dt} = DateTime.from_naive(dt, "Etc/UTC")
    DateTime.to_unix(dt)
  end
end
