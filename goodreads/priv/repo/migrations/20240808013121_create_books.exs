defmodule Goodreads.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :summary, :text
      add :date_of_publication, :date
      add :number_of_sales, :integer
      add :author_id, references(:authors, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:books, [:author_id])
  end
end
