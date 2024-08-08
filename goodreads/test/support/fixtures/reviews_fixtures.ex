defmodule Goodreads.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Goodreads.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        number_of_up_votes: 42,
        review: "some review",
        score: 42
      })
      |> Goodreads.Reviews.create_review()

    review
  end
end
