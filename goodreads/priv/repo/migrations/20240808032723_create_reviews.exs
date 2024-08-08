defmodule Goodreads.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :review, :text
      add :score, :integer
      add :number_of_up_votes, :integer
      add :book_id, references(:books, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:book_id])
  end
end
