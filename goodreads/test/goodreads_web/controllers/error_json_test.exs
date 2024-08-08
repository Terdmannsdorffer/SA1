defmodule GoodreadsWeb.ErrorJSONTest do
  use GoodreadsWeb.ConnCase, async: true

  test "renders 404" do
    assert GoodreadsWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert GoodreadsWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
