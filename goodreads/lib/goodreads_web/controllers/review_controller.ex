defmodule GoodreadsWeb.ReviewController do
  use GoodreadsWeb, :controller

  alias Goodreads.Reviews
  alias Goodreads.Reviews.Review
  alias Goodreads.Library.Book
  alias Goodreads.Repo
  alias Goodreads.OpensearchClient

  def index(conn, _params) do
    reviews = Repo.all(Review) |> Repo.preload(:book)
    render(conn, :index, reviews: reviews)
  end

  def new(conn, _params) do
    books = Repo.all(Book)
    changeset = Review.changeset(%Review{}, %{})
    render(conn, "new.html", changeset: changeset, books: books)
  end

  def create(conn, %{"review" => review_params}) do
    books = Repo.all(Book)
    case Reviews.create_review(review_params) do
      {:ok, review} ->
        # Index the new review in OpenSearch
        OpensearchClient.index_document("reviews", review.id, %{
          book_id: review.book_id,
          content: review.review
        })

        conn
        |> put_flash(:info, "Review created successfully.")
        |> redirect(to: ~p"/reviews/#{review.id}")


      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, books: books)
    end
  end

  def show(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    render(conn, :show, review: review)
  end

  def edit(conn, %{"id" => id}) do
    books = Repo.all(Book)
    review = Reviews.get_review!(id)
    changeset = Reviews.change_review(review)
    render(conn, :edit, review: review, changeset: changeset, books: books)
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    review = Reviews.get_review!(id)

    case Reviews.update_review(review, review_params) do
      {:ok, review} ->
        # Update the review in OpenSearch
        OpensearchClient.index_document("reviews", review.id, %{
          book_id: review.book_id,
          content: review.review
        })

        conn
        |> put_flash(:info, "Review updated successfully.")
        |> redirect(to: ~p"/reviews/#{review.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", review: review, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    {:ok, _review} = Reviews.delete_review(review)

    # Delete the review from OpenSearch
    OpensearchClient.delete_document("reviews", review.id)

    conn
    |> put_flash(:info, "Review deleted successfully.")
    |> redirect(to: ~p"/reviews")
  end

  def search(conn, %{"query" => query}) do
    case OpensearchClient.search("reviews", %{query: %{match: %{content: query}}}) do
      {:ok, results} ->
        reviews = Enum.map(results["hits"]["hits"], &(&1["_source"]))
        render(conn, "search_results.html", reviews: reviews, query: query)

      {:error, _reason} ->
        # Fallback to database search if OpenSearch fails
        reviews = Reviews.search_reviews(query)
        render(conn, "search_results.html", reviews: reviews, query: query)
    end
  end
end
