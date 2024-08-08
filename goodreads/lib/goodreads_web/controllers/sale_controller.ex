defmodule GoodreadsWeb.SaleController do
  use GoodreadsWeb, :controller

  alias Goodreads.Sales
  alias Goodreads.Sales.Sale
  alias Goodreads.Library.Book

  def index(conn, _params) do
    sales = Goodreads.Repo.all(Goodreads.Sales.Sale) |> Goodreads.Repo.preload(:book)
    render(conn, :index, sales: sales)
  end


  def new(conn, _params) do
    books = Goodreads.Repo.all(Goodreads.Library.Book)
    changeset = Sales.change_sale(%Sale{})
    render(conn, :new, changeset: changeset, books: books)
  end


  def create(conn, %{"sale" => sale_params}) do
    case Sales.create_sale(sale_params) do
      {:ok, sale} ->
        conn
        |> put_flash(:info, "Sale created successfully.")
        |> redirect(to: ~p"/sales/#{sale}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sale = Sales.get_sale!(id)
    render(conn, :show, sale: sale)
  end

  def edit(conn, %{"id" => id}) do
    books = Goodreads.Repo.all(Goodreads.Library.Book)
    sale = Sales.get_sale!(id)
    changeset = Sales.change_sale(sale)
    render(conn, :edit, sale: sale, changeset: changeset, books: books)
  end

  def update(conn, %{"id" => id, "sale" => sale_params}) do
    sale = Sales.get_sale!(id)

    case Sales.update_sale(sale, sale_params) do
      {:ok, sale} ->
        conn
        |> put_flash(:info, "Sale updated successfully.")
        |> redirect(to: ~p"/sales/#{sale}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, sale: sale, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sale = Sales.get_sale!(id)
    {:ok, _sale} = Sales.delete_sale(sale)

    conn
    |> put_flash(:info, "Sale deleted successfully.")
    |> redirect(to: ~p"/sales")
  end
end
