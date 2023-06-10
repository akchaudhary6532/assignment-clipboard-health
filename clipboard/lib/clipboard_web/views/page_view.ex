defmodule ClipboardWeb.ShiftView do
  use ClipboardWeb, :view

  def render("list.json", %{data: %{data: data_list, next: next}}) do
    data_list = Enum.map(data_list, &Map.take(&1, ~w(id start end facility_id)a))

    %{data: data_list, next: next}
  end
end
