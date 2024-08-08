defmodule GoodreadsWeb.ReviewController do
  use GoodreadsWeb, :controller

  alias Goodreads.Reviews
  alias Goodreads.Reviews.Review
  alias Goodreads.Library.Book
  alias Goodreads.Repo

  def index(conn, _params) do
    reviews = Goodreads.Repo.all(Goodreads.Reviews.Review) |> Goodreads.Repo.preload(:book)
    render(conn, :index, reviews: reviews)
  end

  def new(conn, _params) do
    books = Goodreads.Repo.all(Goodreads.Library.Book)
    changeset = Goodreads.Reviews.Review.changeset(%Goodreads.Reviews.Review{}, %{})
    render(conn, "new.html", changeset: changeset, books: books)
  end



  def create(conn, %{"review" => review_params}) do
    books = Goodreads.Repo.all(Goodreads.Library.Book)
    case Reviews.create_review(review_params) do
      {:ok, review} ->
        conn
        |> put_flash(:info, "Review created successfully.")
        |> redirect(to: ~p"/reviews/#{review}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, books: books)
    end
  end

  def show(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    render(conn, :show, review: review)
  end

  def edit(conn, %{"id" => id}) do
    books = Goodreads.Repo.all(Goodreads.Library.Book)
    review = Reviews.get_review!(id)
    changeset = Reviews.change_review(review)
    render(conn, :edit, review: review, changeset: changeset, books: books)
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    review = Reviews.get_review!(id)

    case Reviews.update_review(review, review_params) do
      {:ok, review} ->
        conn
        |> put_flash(:info, "Review updated successfully.")
        |> redirect(to: ~p"/reviews/#{review}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, review: review, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    {:ok, _review} = Reviews.delete_review(review)

    conn
    |> put_flash(:info, "Review deleted successfully.")
    |> redirect(to: ~p"/reviews")
  end


  # def top_10_books_with_reviews do
  #   Book
  #   |> order_by([b], desc: b.number_of_sales)
  #   |> limit(10)
  #   |> Repo.all()
  #   |> Repo.preload([:author, reviews: from(r in Review, order_by: [desc: r.number_of_up_votes, desc: r.score])])
  #   |> Enum.map(fn book ->
  #     %{
  #       book: book,
  #       highest_rated_review: Enum.max_by(book.reviews, & &1.score),
  #       lowest_rated_review: Enum.min_by(book.reviews, & &1.score)
  #     }
  #   end)
  # end
end
