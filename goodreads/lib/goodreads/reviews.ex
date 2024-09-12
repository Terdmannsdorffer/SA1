defmodule Goodreads.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Goodreads.Repo
  alias Goodreads.Cache

  alias Goodreads.Reviews.Review

  @doc """
  Returns the list of reviews.

  ## Examples

      iex> list_reviews()
      [%Review{}, ...]

  """
  def list_reviews do
    Repo.all(Review)
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id) do
    cached_score = Cache.get("review_score:#{id}")

    review = Repo.get!(Review, id)

    if cached_score == nil do
      Cache.set("review_score:#{id}", Integer.to_string(review.score))
    else
      review = %{review | score: String.to_integer(cached_score)}
    end

    review
  end

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(%{field: value})
      {:ok, %Review{}}

      iex> create_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a review.

  ## Examples

      iex> update_review(review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Review{} = review, attrs) do
    case review
    |> Review.changeset(attrs)
    |> Repo.update() do
      {:ok, update_review} ->
        Cache.set("review_score:#{update_review.id}", Integer.to_string(update_review.score))
      {:ok, update_review}
      error ->
        error
    end
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(review)
      {:ok, %Review{}}

      iex> delete_review(review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Review{} = review) do
    case Repo.delete(review) do
      {:ok, _deleted_review} ->
      Cached.delete("review_score:#{review.id}")
      {:ok, review}
      error -> error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end
end
