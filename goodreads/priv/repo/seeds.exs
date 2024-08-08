# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Goodreads.Repo.insert!(%Goodreads.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Goodreads.{Repo, Library.Book, Sales.Sale, Reviews.Review, Authors.Author}
import Ecto.Query
import Faker


random_integer = fn min, max ->
  :rand.uniform(max - min + 1) + min - 1
end

# Seed authors
authors =
  for _ <- 1..50 do
    %Author{
      name: Faker.Person.name(),
      date_of_birth: Faker.Date.date_of_birth(),
      country_of_origin: Faker.Address.country(),
      short_description: Faker.Lorem.sentence()
    }
    |> Repo.insert!()
  end

# Seed books
books =
  for _ <- 1..300 do
    author = Enum.random(authors)

    %Book{
      name: Faker.Lorem.words(3) |> Enum.join(" "),  # Generating a random title
      summary: Faker.Lorem.paragraph(),
      date_of_publication: Faker.Date.backward(365 * 20),  # Publication dates within the last 20 years
      number_of_sales: random_integer.(1000, 50000),
      author_id: author.id
    }
    |> Repo.insert!()
  end

# Seed sales
for book <- books do
  for year_offset <- 0..4 do
    %Sale{
      year: Date.utc_today().year - year_offset,
      sales: random_integer.(1000, 50000),
      book_id: book.id
    }
    |> Repo.insert!()
  end
end

# Seed reviews
for book <- books do
  for _ <- 1..random_integer.(1, 10) do
    %Review{
      review: Faker.Lorem.paragraph(),
      score: random_integer.(1, 5),
      number_of_up_votes: random_integer.(0, 1000),
      book_id: book.id
    }
    |> Repo.insert!()
  end
end

IO.puts("Seeding complete!")
