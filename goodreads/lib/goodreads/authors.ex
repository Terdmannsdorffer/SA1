defmodule Goodreads.Authors do
  @moduledoc """
  The Authors context.
  """

  import Ecto.Query, warn: false
  alias Goodreads.Repo
  alias Goodreads.Authors.Author
  alias Goodreads.Library.Book
  alias Goodreads.Sales.Sale
  alias Goodreads.Cache

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

  def list_top_50_books_by_sales do
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

  def list_authors do
    Repo.all(Author)
  end

  def get_author!(id) do
    cached_author = Cache.get("author_info:#{id}")

    if cached_author do
      {:ok, author_data} = Jason.decode(cached_author)
      struct(Author, author_data)
    else
      author = Repo.get!(Author, id)

      author_data = %{
        id: author.id,
        name: author.name,
        date_of_birth: author.date_of_birth,
        country_of_origin: author.country_of_origin,
        short_description: author.short_description
      }

      Cache.set_with_ttl("author_info:#{id}", Jason.encode!(author_data), 3600)
      author
    end
  end

  def create_author(attrs \\ %{}) do
    case %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert() do
      {:ok, author} ->
        Cache.delete("author_info:#{author.id}")  # Clear cache in case of retries
        {:ok, author}
      error ->
        error
    end
  end

  def update_author(%Author{} = author, attrs) do
    case author
         |> Author.changeset(attrs)
         |> Repo.update() do
      {:ok, updated_author} ->
        Cache.delete("author_info:#{updated_author.id}")
        {:ok, updated_author}

      error ->
        error
    end
  end

  def delete_author(%Author{} = author) do
    case Repo.delete(author) do
      {:ok, _deleted_author} ->
        Cache.delete("author_info:#{author.id}")
        {:ok, author}

      error ->
        error
    end
  end

  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end
end
