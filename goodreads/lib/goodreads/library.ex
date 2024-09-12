defmodule Goodreads.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  alias Goodreads.Repo

  alias Goodreads.Library.Book
alias Goodreads.Reviews.Review

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  def top_50_books do
    Book
    |> order_by([b], desc: b.number_of_sales)
    |> limit(50)
    |> preload(:author)
    |> Repo.all()
  end

  def search_books(query) do
    Book
    |> where([b], ilike(b.summary, ^"%#{query}%"))
    |> preload(:author) # Pre-carga la asociación :author
    |> limit(10) # Limita los resultados a 10
    |> Repo.all()
  end

  def update_books_author(author_id, attrs) do
    Book
    |> where([b], b.author_id == ^author_id)
    |> Repo.update_all(set: [author_name: attrs["name"], author_country_of_origin: attrs["country_of_origin"]])
  end


  defp build_query(query) do
    from b in Book,
      where: ilike(b.summary, ^"%#{query}%"),
      select: b
  end


  def top_10_books_with_reviews do
    Book
    |> order_by([b], desc: b.number_of_sales)
    |> limit(10)
    |> Repo.all()
    |> Repo.preload([:author, reviews: from(r in Review, order_by: [desc: r.number_of_up_votes, desc: r.score])])
    |> Enum.map(fn book ->
      %{
        book: book,
        highest_rated_review: Enum.max_by(book.reviews, & &1.score),
        lowest_rated_review: Enum.min_by(book.reviews, & &1.score)
      }
    end)
  end
end
