defmodule Goodreads.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :date_of_birth, :date
    field :country_of_origin, :string
    field :short_description, :string

    has_many :books, Goodreads.Library.Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :date_of_birth, :country_of_origin, :short_description])
    |> validate_required([:name, :date_of_birth, :country_of_origin, :short_description])
  end
end
