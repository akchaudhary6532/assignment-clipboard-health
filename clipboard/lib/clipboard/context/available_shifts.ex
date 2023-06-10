defmodule Clipboard.Context.AvailableShifts do
  @moduledoc """
  In order for a Worker to be eligible for a shift, the rules are:
    * A Facility must be active.
    * The Shift must be active and not claimed by someone else.
    * The Worker must be active.
    * The Worker must not have claimed a shift that collides with the shift they are eligible for.
    * The professions between the Shift and Worker must match.
    * The Worker must have all the documents required by the facilities.
  * Given an active facility, when I request all available shifts within a start and end date, then it will return a list of shifts from that facility in the specified date range.
  * Given an inactive facility, when I request all available shifts within a start and end date, then it will not return a list of shifts from that facility.
  * Given a shift is claimed and is within the requested start and end date, when I request all available shifts within a start and end date, it will not return the claimed shift.
  * The shifts must be grouped by date.
  """

  import Ecto.Query

  alias Clipboard.Schema.DocumentWorker
  alias Clipboard.Schema.Facility
  alias Clipboard.Schema.Shift
  alias Clipboard.Schema.Worker
  alias Clipboard.Repo

  @spec get_all_available_shifts(
          worker_id :: non_neg_integer(),
          page :: non_neg_integer(),
          size :: non_neg_integer(),
          start_date :: NaiveDateTime.t() | nil,
          end_date :: NaiveDateTime.t() | nil,
          facility_id :: non_neg_integer() | nil
        ) :: %{data: list(Shift.t()), next: integer()} | {:error, :worker | :facility | :date_range_error}
  def get_all_available_shifts(worker_id, page, size, start_date, end_date, facility_id) do
    with :ok <- validate_date_range(start_date, end_date),
         {:worker, true} <- ensure_valid_worker(worker_id),
         {:facility, true} <- ensure_valid_facility(facility_id) do
      worker_id
      |> get_eligible_shifts_query(facility_id, start_date, end_date)
      |> Repo.paginate(page, size)
    else
      {:worker, _} -> {:error, :worker}
      {:facility, _} -> {:error, :facility}
      :date_range_error -> {:error, :date_range_error}
    end
  end

  ## Private function
  defp get_eligible_shifts_query(worker_id, facility_id, start_date, end_date) do
    Shift
    |> join(:inner, [s], f in "Facility", on: f.id == s.facility_id and f.is_active == true)
    |> join(:inner, [s, f], w in "Worker", on: w.profession == s.profession and w.is_active == true)
    |> where([s, f, w], s.is_deleted == false and is_nil(s.worker_id) and w.id == ^worker_id)
    |> filter_by_facility(facility_id)
    |> filter_by_date_range(start_date, end_date)
    |> eligible_shift_colliding(worker_id)
    |> worker_has_complete_documents(worker_id)
    |> order_by([s], desc: s.start)
    |> limit(50)
    |> select([s], s)
  end

  @doc """
   * The Worker must have all the documents required by the facilities.
  """
  defp worker_has_complete_documents(query, worker_id) do
    worker_documents =
      DocumentWorker
      |> where([dw], dw.worker_id == ^worker_id)
      |> Repo.all()
      |> Enum.map(& &1.document_id)

    where(
      query,
      [s, f, w],
      fragment(
        "?::bigint[] @>  ARRAY(select fr.document_id from public.\"FacilityRequirement\" fr where fr.facility_id = ?)",
        ^worker_documents,
        f.id
      )
    )
  end

  @doc """
  * The Worker must not have claimed a shift that collides with the shift they are eligible for.
  """
  defp eligible_shift_colliding(query, worker_id) do
    where(
      query,
      [s, f, w],
      fragment(
        "not exists(select * from public.\"Shift\" s2 where s2.is_deleted = false and s2.worker_id = ? and s2.id != ? and s2.start < ? and  ? < s2.end)",
        ^worker_id,
        s.id,
        s.end,
        s.start
      )
    )
  end

  defp filter_by_facility(query, nil), do: query
  defp filter_by_facility(query, facility_id), do: where(query, [s, f], f.id == ^facility_id)

  defp filter_by_date_range(query, start_date, end_date) do
    query
    |> filter_by_start_date(start_date)
    |> filter_by_end_date(end_date)
  end

  defp filter_by_start_date(query, start_date),
    do: if(is_nil(start_date), do: query, else: where(query, [s], s.start >= ^start_date))

  defp filter_by_end_date(query, end_date),
    do: if(is_nil(end_date), do: query, else: where(query, [s], s.end <= ^end_date))

  defp ensure_valid_facility(nil), do: {:facility, true}

  defp ensure_valid_facility(id) do
    case Facility.get_by_id(id) do
      nil -> {:facility, :not_found}
      %Facility{is_active: bool} -> {:facility, bool}
    end
  end

  defp ensure_valid_worker(nil), do: {:worker, :not_found}

  defp ensure_valid_worker(id) do
    case Worker.get_by_id(id) do
      nil -> {:worker, :not_found}
      %Worker{is_active: bool} -> {:worker, bool}
    end
  end

  defp validate_date_range(start_date, end_date) do
    if nil in [start_date, end_date] do
      :ok
    else
      if NaiveDateTime.compare(end_date, start_date) == :gt,
        do: :ok,
        else: :date_range_error
    end
  end
end
