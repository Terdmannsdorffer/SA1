defmodule Goodreads.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :year, :integer
      add :sales, :integer
      add :book_id, references(:books, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:sales, [:book_id])
  end
end
