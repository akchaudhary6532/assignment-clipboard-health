defmodule Clipboard.Test.Context.AvailableShifts do
  use Clipboard.DataCase, async: true

  alias Clipboard.Schema.Facility
  alias Clipboard.Support.Factory
  alias Clipboard.Context.AvailableShifts
  alias Clipboard.Repo
  alias Clipboard.Schema.FacilityRequirement
  alias Clipboard.Schema.DocumentWorker

  @profession_list Clipboard.Constant.profession_list()
  @page 1
  @size 10

  describe "get_all_available_shifts/6" do
    test "success when shift is available and documents match" do
      ## given

      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = get_worker_with_valid_document(shift)

      ## when
      %{data: [result], next: -1} = AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)

      result = Repo.preload(result, [:facility])

      ## then
      assert result == shift
    end

    test "failure when shift is available but all documents do not match" do
      ## given

      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = Factory.insert(:worker, %{profession: shift.profession})
      documents = create_documents(1..10)
      # only partial match
      documents_worker = Enum.take(documents, 3)

      # worker has all required documents
      require_documents_for_facility(documents, shift.facility_id)
      documents_by_worker(documents_worker, worker.id)

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "when shift and worker have different profession" do
      ## given

      # unclaimed shift
      shift = Factory.insert(:shift)
      worker_profession = @profession_list -- [shift.profession]
      worker = Factory.insert(:worker, %{profession: Enum.random(worker_profession)})
      create_valid_documents(shift.facility_id, worker.id)

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "when shift is already claimed" do
      ## given
      another_worker = Factory.insert(:worker)
      # claimed shift
      shift = Factory.insert(:shift, %{worker_id: another_worker.id})
      worker = get_worker_with_valid_document(shift)

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "when worker is disabled" do
      ## given
      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = get_worker_with_valid_document(shift, %{is_active: false})

      ## when
      ## then
      assert {:error, :worker} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "when worker doesn't exist" do
      ## given
      # unclaimed shift
      worker_id = -100

      ## when
      ## then
      assert {:error, :worker} == AvailableShifts.get_all_available_shifts(worker_id, @page, @size, nil, nil, nil)
    end

    test "when facility is disabled" do
      ## given
      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = get_worker_with_valid_document(shift)

      # mark facility as inactive
      shift.facility |> Facility.changeset(%{is_active: false}) |> Repo.update()

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "when given facility is disabled" do
      ## given
      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = get_worker_with_valid_document(shift)

      ## when
      # mark facility as inactive
      shift.facility |> Facility.changeset(%{is_active: false}) |> Repo.update()

      ## then
      assert {:error, :facility} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, shift.facility_id)
    end

    test "success when shift is available but required documents are subset of document available" do
      ## given

      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = Factory.insert(:worker, %{profession: shift.profession})
      documents = create_documents(1..10)
      # only partial match
      documents_required = Enum.take(documents, 3)

      # worker has all required documents
      require_documents_for_facility(documents_required, shift.facility_id)
      documents_by_worker(documents, worker.id)

      ## when
      %{data: [result], next: -1} = AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)

      result = Repo.preload(result, [:facility])

      ## then
      assert result == shift
    end
  end

  describe "get_all_available_shifts/6 : when date range is given as input." do
    setup config do
      shift = Factory.insert(:shift)
      worker = get_worker_with_valid_document(shift)

      another_shift =
        Factory.insert(:shift, %{
          profession: shift.profession,
          start: shift_minutes(shift.end, +5),
          end: shift_minutes(shift.end, +20)
        })

      create_valid_documents(another_shift.facility_id, worker.id)

      Map.merge(%{shift: shift, worker: worker, another_shift: another_shift}, config)
    end

    test "when given both date range", %{shift: shift, worker: worker, another_shift: another_shift} do
      ## given
      ## when
      start_range = shift_minutes(shift.start, -2)
      end_range = shift_minutes(shift.end, +2)
      facility_id = nil

      ## then
      %{data: [result], next: -1} = AvailableShifts.get_all_available_shifts(worker.id, @page, @size, start_range, end_range, facility_id)

      assert result.id == shift.id
    end

    test "when start is greater than end date range", %{shift: shift, worker: worker, another_shift: another_shift} do
      ## given
      ## when
      start_range = shift_minutes(shift.start, -2)
      end_range = shift_minutes(shift.start, -10)
      facility_id = nil

      ## then
      assert {:error, :date_range_error} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, start_range, end_range, facility_id)
    end

    test "when given start date range", %{shift: shift, worker: worker, another_shift: another_shift} do
      ## given
      ## when
      start_range = shift_minutes(shift.end, -2)
      end_range = nil
      facility_id = nil

      ## then
      %{data: [result], next: -1} = AvailableShifts.get_all_available_shifts(worker.id, @page, @size, start_range, end_range, facility_id)

      assert result.id == another_shift.id
    end

    test "when given end date range", %{shift: shift, worker: worker, another_shift: another_shift} do
      ## given
      ## when
      start_range = nil
      end_range = shift_minutes(another_shift.end, -2)
      facility_id = nil

      ## then
      %{data: [result], next: -1} = AvailableShifts.get_all_available_shifts(worker.id, @page, @size, start_range, end_range, facility_id)

      assert result.id == shift.id
    end

    test "when given no date range", %{shift: shift, worker: worker, another_shift: another_shift} do
      ## given
      ## when
      start_range = nil
      end_range = nil
      facility_id = nil

      ## then
      %{data: [result1, result2], next: -1} = AvailableShifts.get_all_available_shifts(worker.id, @page, @size, start_range, end_range, facility_id)

      assert result1.id == another_shift.id
      assert result2.id == shift.id
    end
  end

  describe "get_all_available_shifts/6 : when shift is not claimed but worker has claimed another shift that collides with it." do
    setup config do
      # unclaimed shift
      shift = Factory.insert(:shift)
      worker = get_worker_with_valid_document(shift)

      Map.merge(%{shift: shift, worker: worker}, config)
    end

    test "start time colliding with another claimed shift", %{shift: shift, worker: worker} do
      ## given
      # claimed shift
      another_shift = Factory.insert(:shift, %{worker_id: worker.id, start: shift_minutes(shift.start, 5), end: shift_minutes(shift.end, 5)})

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "end time colliding", %{shift: shift, worker: worker} do
      ## given

      # claimed shift
      _another_shift = Factory.insert(:shift, %{worker_id: worker.id, start: shift_minutes(shift.start, -5), end: shift_minutes(shift.end, -5)})

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end

    test "one time is subset of another", %{shift: shift, worker: worker} do
      ## given

      # claimed shift
      _another_shift = Factory.insert(:shift, %{worker_id: worker.id, start: shift_minutes(shift.start, +5), end: shift_minutes(shift.end, -5)})

      ## when
      ## then
      assert %{data: [], next: -1} == AvailableShifts.get_all_available_shifts(worker.id, @page, @size, nil, nil, nil)
    end
  end

  def get_worker_with_valid_document(shift, params \\ %{}) do
    # same profession
    opts = Map.merge(%{profession: shift.profession}, params)

    worker = Factory.insert(:worker, opts)
    create_valid_documents(shift.facility_id, worker.id)

    worker
  end

  def create_valid_documents(facility_id, worker_id) do
    documents = create_documents(1..10)

    # worker has all required documents
    require_documents_for_facility(documents, facility_id)
    documents_by_worker(documents, worker_id)
  end

  defp create_documents(count) do
    Enum.map(count, fn _ -> Factory.insert(:document) end)
  end

  defp documents_by_worker(documents, worker_id) do
    Enum.each(documents, fn doc ->
      %{document_id: doc.id, worker_id: worker_id}
      |> DocumentWorker.new()
      |> Repo.insert()
    end)
  end

  defp require_documents_for_facility(documents, facility_id) do
    Enum.each(documents, fn doc ->
      %{document_id: doc.id, facility_id: facility_id}
      |> FacilityRequirement.new()
      |> Repo.insert()
    end)
  end

  defp shift_minutes(time, shift), do: NaiveDateTime.add(time, shift, :minute)
end
