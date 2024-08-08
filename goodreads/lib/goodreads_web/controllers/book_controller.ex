
defmodule GoodreadsWeb.BookController do
  use GoodreadsWeb, :controller

  alias Goodreads.Library
  alias Goodreads.Library.Book
  alias Goodreads.Repo

  def index(conn, _params) do
    books = Library.list_books() |> Repo.preload(:author)
    render(conn, :index, books: books)
  end

  def new(conn, _params) do
    changeset = Library.change_book(%Book{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"book" => book_params}) do
    case Library.create_book(book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book = Library.get_book!(id) |> Repo.preload(:author)
    render(conn, :show, book: book)
  end

  def edit(conn, %{"id" => id}) do
    book = Library.get_book!(id)
    changeset = Library.change_book(book)
    render(conn, :edit, book: book, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Library.get_book!(id)

    case Library.update_book(book, book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, book: book, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Library.get_book!(id)
    {:ok, _book} = Library.delete_book(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: ~p"/books")
  end

  def top_books(conn, _params) do
    books = Library.top_50_books()
    render(conn, "top_books.html", books: books)
  end

  def top_books_with_reviews(conn, _params) do
    books_with_reviews = Library.top_10_books_with_reviews()
    render(conn, "top_books_with_reviews.html", books_with_reviews: books_with_reviews)
  end


  def search(conn, _params) do
    render(conn, "search.html")
  end




end
