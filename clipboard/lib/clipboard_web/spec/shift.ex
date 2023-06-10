defmodule ClipboardWeb.Spec.Shift do
  alias OpenApiSpex.Schema

  defmodule AvailableResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Shift Id"},
        start: %Schema{type: :integer, description: "Start shift unix timestamp"},
        end: %Schema{type: :integer, description: "End shift unix timestamp"},
        facility_id: %Schema{type: :integer, description: "Facility id"}
      },
      required: [:id, :start, :end, :facility_id],
      example: %{
        "id" => 123,
        "start" => 1685208258,
        "end" => 1785208258,
        "facility_id" => 1
      }
    })
  end
end
