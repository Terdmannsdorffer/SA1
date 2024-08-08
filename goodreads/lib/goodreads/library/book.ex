defmodule Goodreads.Library.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :name, :string
    field :summary, :string
    field :date_of_publication, :date
    field :number_of_sales, :integer

    belongs_to :author, Goodreads.Authors.Author
    has_many :reviews, Goodreads.Library.Review

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :summary, :date_of_publication, :number_of_sales, :author_id])
    |> validate_required([:name, :summary, :date_of_publication, :number_of_sales, :author_id])
  end
end
