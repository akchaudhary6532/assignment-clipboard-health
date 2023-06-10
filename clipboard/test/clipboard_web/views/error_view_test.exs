defmodule ClipboardWeb.ErrorViewTest do
  use ClipboardWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(ClipboardWeb.ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ClipboardWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
