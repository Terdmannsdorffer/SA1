defmodule Goodreads.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyApp.Cache

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

  @doc false
  def after_insert(changeset) do
    store_score_in_cache(changeset)
    changeset
  end

  @doc false
  def after_update(changeset) do
    store_score_in_cache(changeset)
    changeset
  end

  defp store_score_in_cache(%Ecto.Changeset{valid?: true, changes: %{score: score}} = changeset) do
    review_id = get_field(changeset, :id) || get_field(changeset.data, :id)
    Cache.set("review_score:#{review_id}", Integer.to_string(score))
  end
  defp store_score_in_cache(_changeset), do: :ok
end
