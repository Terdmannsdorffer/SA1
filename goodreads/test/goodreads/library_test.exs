defmodule Goodreads.LibraryTest do
  use Goodreads.DataCase

  alias Goodreads.Library

  describe "books" do
    alias Goodreads.Library.Book

    import Goodreads.LibraryFixtures

    @invalid_attrs %{name: nil, summary: nil, date_of_publication: nil, number_of_sales: nil}

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Library.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Library.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{name: "some name", summary: "some summary", date_of_publication: ~D[2024-08-07], number_of_sales: 42}

      assert {:ok, %Book{} = book} = Library.create_book(valid_attrs)
      assert book.name == "some name"
      assert book.summary == "some summary"
      assert book.date_of_publication == ~D[2024-08-07]
      assert book.number_of_sales == 42
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      update_attrs = %{name: "some updated name", summary: "some updated summary", date_of_publication: ~D[2024-08-08], number_of_sales: 43}

      assert {:ok, %Book{} = book} = Library.update_book(book, update_attrs)
      assert book.name == "some updated name"
      assert book.summary == "some updated summary"
      assert book.date_of_publication == ~D[2024-08-08]
      assert book.number_of_sales == 43
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_book(book, @invalid_attrs)
      assert book == Library.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Library.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Library.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Library.change_book(book)
    end
  end
end
