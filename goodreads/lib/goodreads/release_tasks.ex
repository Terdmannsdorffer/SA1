
# defmodule Goodreads.ReleaseTasks do
#   @app :goodreads

#   def migrate do
#     load_app()

#     for repo <- repos() do
#       {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
#       IO.puts("Migrations complete.")
#     end
#   end

#   def seed do
#     load_app()

#     for repo <- repos() do
#       if has_data?(repo) do
#         IO.puts("Database already has data, skipping seed.")
#       else
#         IO.puts("No data found, running seeds...")
#         case Ecto.Migrator.with_repo(repo, &run_seeds_for/1) do
#           {:ok, _, _} -> IO.puts("Seeding complete!")
#           {:error, reason} -> IO.puts("Seeding failed: #{inspect(reason)}")
#         end
#       end
#     end
#   end

#   defp has_data?(repo) do
#     # Check if there are any records in a key table (e.g., "users" or any other central table)
#     query = "SELECT COUNT(*) FROM authors" # Replace with an appropriate table name
#     case Ecto.Adapters.SQL.query(repo, query, []) do
#       {:ok, %{rows: [[count]]}} when count > 0 -> true
#       _ -> false
#     end
#   end

#   defp run_seeds_for(repo) do
#     seed_script = Path.join([priv_dir(repo), "seeds.exs"])

#     if File.exists?(seed_script) do
#       IO.puts("Running seed script: #{seed_script}")
#       Code.eval_file(seed_script)
#     else
#       IO.puts("Seed script not found: #{seed_script}")
#     end
#   end

#   defp priv_dir(repo) do
#     app = Keyword.get(repo.config, :otp_app)
#     "#{:code.priv_dir(app)}/repo"
#   end

#   defp repos do
#     Application.load(@app)
#     Application.fetch_env!(@app, :ecto_repos)
#   end

#   defp load_app do
#     Application.load(@app)
#   end
# end

defmodule Goodreads.ReleaseTasks do
  @app :goodreads
  alias Goodreads.OpensearchClient
  alias Goodreads.Authors.Author
  alias Goodreads.Library.Book
  alias Goodreads.Reviews.Review

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      IO.puts("Migrations complete.")
    end
  end

  def seed do
    load_app()

    for repo <- repos() do
      if has_data?(repo) do
        IO.puts("Database already has data, skipping seed.")
      else
        IO.puts("No data found, running seeds...")
        case Ecto.Migrator.with_repo(repo, &run_seeds_for/1) do
          {:ok, _, _} ->
            IO.puts("Seeding complete!")
            index_opensearch(repo)  # Add OpenSearch indexing after seeding
          {:error, reason} -> IO.puts("Seeding failed: #{inspect(reason)}")
        end
      end
    end
  end

  defp index_opensearch(repo) do
    index_authors(repo)
    index_books(repo)
    index_reviews(repo)
  end

  defp index_authors(repo) do
    try do
      authors = repo.all(Author)
      Enum.each(authors, fn author ->
        document = %{
          id: author.id,
          name: author.name,
          date_of_birth: author.date_of_birth,
          country_of_origin: author.country_of_origin,
          short_description: author.short_description,
          books: Enum.map(author.books, & &1.name)  # Assuming books have been preloaded
        }
        OpensearchClient.index_document("authors", author.id, document)
      end)
      IO.puts("Authors indexing complete.")
    rescue
      exception ->
        IO.puts("Error indexing authors to OpenSearch: #{inspect(exception)}")
    end
  end

  defp index_books(repo) do
    try do
      books = repo.all(Book)
      Enum.each(books, fn book ->
        document = %{
          id: book.id,
          name: book.name,
          summary: book.summary,
          date_of_publication: book.date_of_publication,
          number_of_sales: book.number_of_sales,
          author_id: book.author_id  # Relating back to the author
        }
        OpensearchClient.index_document("books", book.id, document)
      end)
      IO.puts("Books indexing complete.")
    rescue
      exception ->
        IO.puts("Error indexing books to OpenSearch: #{inspect(exception)}")
    end
  end

  defp index_reviews(repo) do
    try do
      reviews = repo.all(Review)
      Enum.each(reviews, fn review ->
        document = %{
          id: review.id,
          review: review.review,
          score: review.score,
          number_of_up_votes: review.number_of_up_votes,
          book_id: review.book_id  # Relating back to the book
        }
        OpensearchClient.index_document("reviews", review.id, document)
      end)
      IO.puts("Reviews indexing complete.")
    rescue
      exception ->
        IO.puts("Error indexing reviews to OpenSearch: #{inspect(exception)}")
    end
  end

  defp has_data?(repo) do
    query = "SELECT COUNT(*) FROM authors"
    case Ecto.Adapters.SQL.query(repo, query, []) do
      {:ok, %{rows: [[count]]}} when count > 0 -> true
      _ -> false
    end
  end

  defp run_seeds_for(repo) do
    seed_script = Path.join([priv_dir(repo), "seeds.exs"])

    if File.exists?(seed_script) do
      IO.puts("Running seed script: #{seed_script}")
      Code.eval_file(seed_script)
    else
      IO.puts("Seed script not found: #{seed_script}")
    end
  end

  defp priv_dir(repo) do
    app = Keyword.get(repo.config, :otp_app)
    "#{:code.priv_dir(app)}/repo"
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
