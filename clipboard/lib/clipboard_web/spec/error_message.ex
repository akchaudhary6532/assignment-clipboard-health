defmodule ClipboardWeb.Spec.ErrorMessage do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "error",
    type: :object,
    properties: %{
      message: %Schema{type: :string, description: "Error message"}
    }
  })

end
