defmodule GoodreadsWeb.AuthorController do
  use GoodreadsWeb, :controller  # Ensure Phoenix's controller macros and helpers are imported

  alias Goodreads.Authors
  alias Goodreads.Authors.Author
  alias Goodreads.Repo
  alias Goodreads.OpensearchClient
  alias Goodreads.Books
  alias GoodreadsWeb.Router.Helpers, as: Routes


  def index(conn, _params) do
    authors = Authors.list_authors()
    render(conn, :index, authors: authors)
  end

  def new(conn, _params) do
    changeset = Authors.change_author(%Author{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"author" => author_params}) do
    # Handle file upload and update author_params with the image path
    author_params = handle_file_upload(author_params, :author)

    case Authors.create_author(author_params) do
      {:ok, author} ->
        # Indexing author information without image path
        OpensearchClient.index_document("authors", author.id, %{
          name: author.name,
          date_of_birth: author.date_of_birth,
          country_of_origin: author.country_of_origin,
          short_description: author.short_description
        })

        conn
        |> put_flash(:info, "Author created successfully.")
        |> redirect(to: ~p"/authors/#{author.id}")


      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    author = Authors.get_author!(id)
    render(conn, :show, author: author)
  end

  def edit(conn, %{"id" => id}) do
    author = Authors.get_author!(id)  # Use caching version to fetch author
    changeset = Authors.change_author(author)
    render(conn, :edit, author: author, changeset: changeset)
  end


  def update(conn, %{"id" => id, "author" => author_params}) do
    author = Authors.get_author!(id)

    # Handle file upload and update author_params with the image path
    author_params = handle_file_upload(author_params, :author)

    case Authors.update_author(author, author_params) do
      {:ok, author} ->
        # Indexing author information without image path
        OpensearchClient.index_document("authors", author.id, %{
          name: author.name,
          date_of_birth: author.date_of_birth,
          country_of_origin: author.country_of_origin,
          short_description: author.short_description
        })

        conn
        |> put_flash(:info, "Author updated successfully.")
        |> redirect(to: ~p"/authors/#{author.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, author: author, changeset: changeset)
    end
  end



  def delete(conn, %{"id" => id}) do
    author = Repo.get!(Author, id)

    case Authors.delete_author(author) do
      {:ok, _author} ->
        # Delete the author from OpenSearch
        OpensearchClient.delete_document("authors", id)

        conn
        |> put_flash(:info, "Author deleted successfully.")
        |> redirect(to: ~p"/authors")
        # Ensure correct redirect after deletion

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Failed to delete author.")
        |> redirect(to: ~p"/authors")
        # Ensure correct redirect on error
    end
  end

  defp handle_file_upload(params, resource_type) do
    # Define the directory where images will be stored based on resource type
    upload_directory = "priv/static/uploads/#{resource_type}_images"

    # Ensure the upload directory exists
    File.mkdir_p!(upload_directory)

    # Extract the upload field names and files from params (if available)
    cover_image = Map.get(params, "cover_image")
    profile_image = Map.get(params, "profile_image")

    # Helper function to handle individual file uploads
    upload_file = fn file, field_name ->
      case file do
        %Plug.Upload{path: path, filename: filename} ->
          # Generate a unique filename
          unique_filename = "#{UUID.uuid4()}_#{filename}"

          # Define the destination path
          destination_path = Path.join(upload_directory, unique_filename)

          # Copy the file to the destination path
          File.cp!(path, destination_path)

          # Update the params with the new file path
          params
          |> Map.put("#{field_name}_path", unique_filename)
        _ ->
          params
      end
    end

    # Handle cover image upload (if present)
    params = if cover_image, do: upload_file.(cover_image, "cover_image"), else: params

    # Handle profile image upload (if present)
    params = if profile_image, do: upload_file.(profile_image, "profile_image"), else: params

    # Return updated params
    params
  end

  def authors_stats(conn, _params) do
    authors = Authors.list_authors_with_book_counts_and_sales()
    render(conn, "authors_stats.html", authors: authors)
  end

  def top_50(conn, _params) do
    books = Authors.list_top_50_books_by_sales()
    render(conn, "top_50.html", books: books)
  end
end
