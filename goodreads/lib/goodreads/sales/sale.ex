defmodule Goodreads.Sales.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales" do
    field :year, :integer
    field :sales, :integer

    belongs_to :book, Goodreads.Library.Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:year, :sales, :book_id])
    |> validate_required([:year, :sales, :book_id])
  end
end
