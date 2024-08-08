defmodule Goodreads.Authors do
  @moduledoc """
  The Authors context.
  """

  import Ecto.Query, warn: false
  alias Goodreads.Repo

  alias Goodreads.Authors.Author


  # def list_authors_with_book_counts do
  #   from(a in Author,
  #     left_join: b in assoc(a, :books),
  #     group_by: [a.id, a.name],
  #     select: %{
  #       id: a.id,
  #       name: a.name,
  #       book_count: count(b.id)
  #     }
  #   )
  #   |> Repo.all()
  # end

  def list_authors_with_book_counts do
    from(a in Author,
      left_join: b in assoc(a, :books),
      left_join: r in assoc(b, :reviews),
      group_by: [a.id, a.name],
      select: %{
        id: a.id,
        name: a.name,
        book_count: count(b.id),
        average_score: avg(r.score)
      }
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
