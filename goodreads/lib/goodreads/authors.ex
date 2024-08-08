defmodule Goodreads.Authors do
  @moduledoc """
  The Authors context.
  """

  import Ecto.Query, warn: false
  alias Goodreads.Repo

  alias Goodreads.Authors.Author
  alias Goodreads.Library.Book
  alias Goodreads.Sales.Sale




  def list_authors_with_book_counts_and_sales do
    from(a in Author,
      left_join: b in assoc(a, :books),
      left_join: r in assoc(b, :reviews),
      left_join: s in assoc(b, :sales),
      group_by: [a.id, a.name],
      select: %{
        id: a.id,
        name: a.name,
        book_count: count(b.id),
        average_score: avg(r.score),
        total_sales: coalesce(sum(s.sales), 0)
      }
    )
    |> Repo.all()
  end


  # def list_top_50_books_by_sales do
  #   # Subconsulta para obtener el total de ventas por autor
  #   subquery = from(a in Author,
  #     left_join: b in assoc(a, :books),
  #     left_join: s in assoc(b, :sales),
  #     group_by: a.id,
  #     select: %{
  #       id: a.id,
  #       total_sales: coalesce(sum(s.sales), 0)
  #     }
  #   )

  #   from(b in Book,
  #     left_join: a in assoc(b, :author),
  #     left_join: s in assoc(b, :sales),
  #     left_join: sub in subquery(subquery),
  #     on: a.id == sub.id,
  #     group_by: [b.id, a.id, sub.total_sales],
  #     select: %{
  #       id: b.id,
  #       name: b.name,
  #       total_sales: coalesce(sum(s.sales), 0),
  #       author_name: a.name,
  #       author_total_sales: sub.total_sales
  #     },
  #     order_by: [desc: coalesce(sum(s.sales), 0)],
  #     limit: 50
  #   )
  #   |> Repo.all()
  # end

  def list_top_50_books_by_sales do
    # Subconsulta para obtener el top 5 ventas por año
    top_5_per_year_subquery = from(s in Sale,
      group_by: [s.year, s.book_id],
      select: %{
        year: s.year,
        book_id: s.book_id,
        total_sales: coalesce(sum(s.sales), 0)
      },
      order_by: [desc: coalesce(sum(s.sales), 0)]
    )
    |> subquery()

    # Subconsulta para marcar si el libro estuvo en el top 5
    top_5_books_subquery = from(b in Book,
      join: s in assoc(b, :sales),
      join: top_5 in ^top_5_per_year_subquery,
      on: s.book_id == top_5.book_id and s.year == top_5.year,
      group_by: [b.id, s.year],
      select: %{
        book_id: b.id,
        year: s.year,
        is_top_5: count(top_5.book_id) > 0
      }
    )
    |> subquery()

    from(b in Book,
      join: a in assoc(b, :author),
      left_join: s in assoc(b, :sales),
      left_join: top_5 in ^top_5_books_subquery,
      on: b.id == top_5.book_id,
      group_by: [b.id, a.id, top_5.is_top_5],
      select: %{
        id: b.id,
        name: b.name,
        total_sales: coalesce(sum(s.sales), 0),
        author_name: a.name,
        author_total_sales: coalesce(sum(s.sales), 0),
        top_5_status: fragment("CASE WHEN ? THEN 'Yes' ELSE 'No' END", top_5.is_top_5)
      },
      order_by: [desc: coalesce(sum(s.sales), 0)],
      limit: 50
    )
    |> Repo.all()
  end



  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end
end
