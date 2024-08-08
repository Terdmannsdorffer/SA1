defmodule GoodreadsWeb.SaleControllerTest do
  use GoodreadsWeb.ConnCase

  import Goodreads.SalesFixtures

  @create_attrs %{year: 42, sales: 42}
  @update_attrs %{year: 43, sales: 43}
  @invalid_attrs %{year: nil, sales: nil}

  describe "index" do
    test "lists all sales", %{conn: conn} do
      conn = get(conn, ~p"/sales")
      assert html_response(conn, 200) =~ "Listing Sales"
    end
  end

  describe "new sale" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/sales/new")
      assert html_response(conn, 200) =~ "New Sale"
    end
  end

  describe "create sale" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/sales", sale: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/sales/#{id}"

      conn = get(conn, ~p"/sales/#{id}")
      assert html_response(conn, 200) =~ "Sale #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/sales", sale: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Sale"
    end
  end

  describe "edit sale" do
    setup [:create_sale]

    test "renders form for editing chosen sale", %{conn: conn, sale: sale} do
      conn = get(conn, ~p"/sales/#{sale}/edit")
      assert html_response(conn, 200) =~ "Edit Sale"
    end
  end

  describe "update sale" do
    setup [:create_sale]

    test "redirects when data is valid", %{conn: conn, sale: sale} do
      conn = put(conn, ~p"/sales/#{sale}", sale: @update_attrs)
      assert redirected_to(conn) == ~p"/sales/#{sale}"

      conn = get(conn, ~p"/sales/#{sale}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, sale: sale} do
      conn = put(conn, ~p"/sales/#{sale}", sale: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Sale"
    end
  end

  describe "delete sale" do
    setup [:create_sale]

    test "deletes chosen sale", %{conn: conn, sale: sale} do
      conn = delete(conn, ~p"/sales/#{sale}")
      assert redirected_to(conn) == ~p"/sales"

      assert_error_sent 404, fn ->
        get(conn, ~p"/sales/#{sale}")
      end
    end
  end

  defp create_sale(_) do
    sale = sale_fixture()
    %{sale: sale}
  end
end
