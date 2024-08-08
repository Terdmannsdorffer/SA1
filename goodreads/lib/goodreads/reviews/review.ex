defmodule Goodreads.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :review, :string
    field :score, :integer
    field :number_of_up_votes, :integer

    belongs_to :book, Goodreads.Library.Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:review, :score, :number_of_up_votes, :book_id])
    |> validate_required([:review, :score, :number_of_up_votes, :book_id])
  end
end
