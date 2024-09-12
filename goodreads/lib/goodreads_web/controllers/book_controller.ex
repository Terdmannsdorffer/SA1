
# defmodule GoodreadsWeb.BookController do
#   use GoodreadsWeb, :controller

#   alias Goodreads.Library
#   alias Goodreads.Library.Book
#   alias Goodreads.Repo

#   def index(conn, _params) do
#     books = Library.list_books() |> Repo.preload(:author)
#     render(conn, :index, books: books)
#   end

#   def new(conn, _params) do
#     changeset = Library.change_book(%Book{})
#     render(conn, :new, changeset: changeset)
#   end

#   def create(conn, %{"book" => book_params}) do
#     case Library.create_book(book_params) do
#       {:ok, book} ->
#         conn
#         |> put_flash(:info, "Book created successfully.")
#         |> redirect(to: ~p"/books/#{book}")

#       {:error, %Ecto.Changeset{} = changeset} ->
#         render(conn, :new, changeset: changeset)
#     end
#   end

#   def show(conn, %{"id" => id}) do
#     book = Library.get_book!(id) |> Repo.preload(:author)
#     render(conn, :show, book: book)
#   end

#   def edit(conn, %{"id" => id}) do
#     book = Library.get_book!(id)
#     changeset = Library.change_book(book)
#     render(conn, :edit, book: book, changeset: changeset)
#   end

#   def update(conn, %{"id" => id, "book" => book_params}) do
#     book = Library.get_book!(id)

#     case Library.update_book(book, book_params) do
#       {:ok, book} ->
#         conn
#         |> put_flash(:info, "Book updated successfully.")
#         |> redirect(to: ~p"/books/#{book}")

#       {:error, %Ecto.Changeset{} = changeset} ->
#         render(conn, :edit, book: book, changeset: changeset)
#     end
#   end

#   def delete(conn, %{"id" => id}) do
#     book = Library.get_book!(id)
#     {:ok, _book} = Library.delete_book(book)

#     conn
#     |> put_flash(:info, "Book deleted successfully.")
#     |> redirect(to: ~p"/books")
#   end

#   def top_books(conn, _params) do
#     books = Library.top_50_books()
#     render(conn, "top_books.html", books: books)
#   end

#   def top_books_with_reviews(conn, _params) do
#     books_with_reviews = Library.top_10_books_with_reviews()
#     render(conn, "top_books_with_reviews.html", books_with_reviews: books_with_reviews)
#   end


#   def search(conn, %{"query" => query}) do
#     books = Library.search_books(query)
#     render(conn, "search.html", books: books, query: query)
#   end



# end

defmodule GoodreadsWeb.BookController do
  use GoodreadsWeb, :controller

  alias Goodreads.Library
  alias Goodreads.Library.Book
  alias Goodreads.Repo
  alias Goodreads.OpensearchClient  # Module to interact with OpenSearch

  def index(conn, _params) do
    books = Library.list_books() |> Repo.preload(:author)
    render(conn, :index, books: books)
  end

  def new(conn, _params) do
    changeset = Library.change_book(%Book{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"book" => book_params}) do
    # Handle file upload and update book_params with the image path
    # book_params = handle_image_upload(book_params, :book)

    case Library.create_book(book_params) do
      {:ok, book} ->
        # Reload the book to ensure associations are loaded
        book = book |> Repo.preload(:author)

        # Index the newly created book in OpenSearch without image path
        OpensearchClient.index_document("books", book.id, %{
          id: book.id,
          name: book.name,  # Correct field name
          summary: book.summary,
          author: book.author.name  # Ensure that author is preloaded
        })

        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: Routes.book_path(conn, :show, book.id))

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

    # Handle file upload and update book_params with the image path
    # book_params = handle_image_upload(book_params, :book)

    case Library.update_book(book, book_params) do
      {:ok, book} ->
        # Update the book in OpenSearch after successful update in DB
        OpensearchClient.index_document("books", book.id, %{
          id: book.id,
          name: book.name,  # Using `name` instead of `title`
          summary: book.summary,
          author: book.author.name  # Ensure that author.name is accessible
        })

        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: Routes.book_path(conn, :show, book.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, book: book, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Library.get_book!(id)
    {:ok, _book} = Library.delete_book(book)

    # Remove the book from OpenSearch
    OpensearchClient.delete_document("books", book.id)

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


  def search(conn, params) do

    case Map.get(params, "query") do
      nil ->
        # Si no hay query, renderiza la página sin resultados
        render(conn, "search.html", books: [], query: nil)

      query ->
        # Realizar la búsqueda en la base de datos usando el módulo Library
        books = Library.search_books(query)
        render(conn, "search.html", books: books, query: query)
    end
  end

  def query_of_all_books(conn, %{"query" => query}) do
    IO.puts("Iniciando la búsqueda de todos los libros en OpenSearch")

    # Log the raw query parameter
    IO.inspect(query, label: "Raw query")

    # Ensure query is not nil, normalize if present, or set to an empty string if nil
    normalized_query =
      case query do
        nil -> ""
        _ -> String.downcase(query)
      end

    # Log the normalized query
    IO.inspect(normalized_query, label: "Normalized query")

    case search_all_books_in_opensearch() do
      {:ok, books} ->  # Expecting the list directly
        IO.inspect(books, label: "Libros")

        # Filtrar los libros según la palabra de búsqueda en el resumen usando normalized_query
        filtered_books = filter_books_by_query(books, normalized_query)

        # Imprimir los libros filtrados
        IO.inspect(filtered_books, label: "Libros filtrados")

        # Retornar los libros filtrados en formato JSON
        json(conn, %{status: "success", books: filtered_books})

      {:error, reason} ->
        IO.inspect(reason, label: "Error en la búsqueda de OpenSearch")
        json(conn, %{status: "error", message: "Failed to fetch books from OpenSearch", reason: inspect(reason)})
    end
  end



  # Función para filtrar libros basados en la consulta
  defp filter_books_by_query(books, query) do
    query_lower = String.downcase(query)

    Enum.filter(books, fn book ->
      summary_lower = String.downcase(book["summary"])
      String.contains?(summary_lower, query_lower)
    end)
  end


  defp handle_file_upload(params) do
    # Define the directory where book cover images will be stored
    upload_directory = "priv/static/uploads/book_covers"

    # Ensure the upload directory exists
    File.mkdir_p!(upload_directory)

    # Extract the file from params (assuming the file is in a field called "cover_image")
    %{"cover_image" => cover_image} = params

    # Helper function to handle individual file upload
    upload_file = fn file, field_name ->
      case file do
        %Plug.Upload{path: path, filename: filename} ->
          # Generate a unique filename to avoid conflicts
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

    # Handle book cover image upload
    params = upload_file.(cover_image, "cover_image")

    # Return updated params
    params
  end


# Función para obtener todos los libros desde OpenSearch
  def all_books(conn, _params) do
    IO.puts("Iniciando la búsqueda de todos los libros en OpenSearch")

    case search_all_books_in_opensearch() do
      {:ok, books} ->
        # Imprimir los libros obtenidos de OpenSearch
        IO.inspect(books, label: "Libros obtenidos de OpenSearch")

        # Si OpenSearch responde correctamente, retornar libros en formato JSON
        json(conn, %{status: "success", books: books})

      {:error, reason} ->
        # Imprimir la razón del error
        IO.inspect(reason, label: "Error en la búsqueda de OpenSearch")

        # Si OpenSearch falla, retornar un mensaje de error en JSON
        json(conn, %{status: "error", message: "Failed to fetch books from OpenSearch", reason: inspect(reason)})
    end
  end

# Función que busca todos los libros en OpenSearch
  defp search_all_books_in_opensearch do
    opensearch_url = "http://opensearch-node1:9200/books/_search"
    body = %{
      query: %{
        match_all: %{}
      }
    }

    # Imprimir el cuerpo de la solicitud a OpenSearch
    IO.inspect(body, label: "Cuerpo de la solicitud a OpenSearch")

    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(opensearch_url, Jason.encode!(body), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        # Imprimir la respuesta bruta de OpenSearch
        IO.puts("Respuesta de OpenSearch con código 200")
        IO.inspect(response_body, label: "Cuerpo de la respuesta de OpenSearch")

        case Jason.decode(response_body) do
          {:ok, decoded_body} ->
            # Imprimir la respuesta decodificada de OpenSearch
            IO.inspect(decoded_body, label: "Respuesta decodificada de OpenSearch")
            books = extract_books_from_opensearch_response(decoded_body)
            {:ok, books}

          {:error, decode_error} ->
            # Imprimir el error de decodificación
            IO.inspect(decode_error, label: "Error al decodificar la respuesta de OpenSearch")
            {:error, {:invalid_response, decode_error}}
        end

      {:ok, %HTTPoison.Response{status_code: status}} when status in 400..499 ->
        IO.puts("Error de OpenSearch: Código de estado #{status}")
        {:error, {:opensearch_error, status}}

      {:error, connection_error} ->
        # Imprimir el error de conexión
        IO.inspect(connection_error, label: "Error de conexión con OpenSearch")
        {:error, {:connection_failed, connection_error}}
    end
  end

  def check_opensearch(conn, _params) do
    #opensearch_url = "http://localhost:9200"
    opensearch_url = "http://opensearch-node1:9200"

    case HTTPoison.get(opensearch_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        # Imprimir la respuesta bruta de OpenSearch
        IO.puts("Respuesta de OpenSearch con código 200")
        IO.inspect(response_body, label: "Cuerpo de la respuesta de OpenSearch")

        # Responder con un mensaje de éxito en formato JSON
        json(conn, %{status: "success", message: "OpenSearch está en funcionamiento."})

      {:ok, %HTTPoison.Response{status_code: status}} when status in 400..499 ->
        IO.puts("Error de OpenSearch: Código de estado #{status}")
        json(conn, %{status: "error", message: "Error de OpenSearch", code: status})

      {:error, connection_error} ->
        IO.inspect(connection_error, label: "Error de conexión con OpenSearch")
        json(conn, %{status: "error", message: "No se puede conectar a OpenSearch", reason: inspect(connection_error)})
    end
  end
  # Función para extraer libros de la respuesta de OpenSearch
  defp extract_books_from_opensearch_response(response) do
    hits = get_in(response, ["hits", "hits"])

    Enum.map(hits, fn hit ->
      %{
        id: get_in(hit, ["_id"]),
        name: get_in(hit, ["_source", "name"]),
        summary: get_in(hit, ["_source", "summary"]),
        author: get_in(hit, ["_source", "author"])
      }
    end)
  end



end
