defmodule Goodreads.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Goodreads.Library` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        date_of_publication: ~D[2024-08-07],
        name: "some name",
        number_of_sales: 42,
        summary: "some summary"
      })
      |> Goodreads.Library.create_book()

    book
  end
end
