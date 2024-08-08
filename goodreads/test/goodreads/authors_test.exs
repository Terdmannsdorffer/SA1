defmodule Goodreads.AuthorsTest do
  use Goodreads.DataCase

  alias Goodreads.Authors

  describe "authors" do
    alias Goodreads.Authors.Author

    import Goodreads.AuthorsFixtures

    @invalid_attrs %{name: nil, date_of_birth: nil, country_of_origin: nil, short_description: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Authors.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Authors.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{name: "some name", date_of_birth: ~D[2024-08-07], country_of_origin: "some country_of_origin", short_description: "some short_description"}

      assert {:ok, %Author{} = author} = Authors.create_author(valid_attrs)
      assert author.name == "some name"
      assert author.date_of_birth == ~D[2024-08-07]
      assert author.country_of_origin == "some country_of_origin"
      assert author.short_description == "some short_description"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authors.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      update_attrs = %{name: "some updated name", date_of_birth: ~D[2024-08-08], country_of_origin: "some updated country_of_origin", short_description: "some updated short_description"}

      assert {:ok, %Author{} = author} = Authors.update_author(author, update_attrs)
      assert author.name == "some updated name"
      assert author.date_of_birth == ~D[2024-08-08]
      assert author.country_of_origin == "some updated country_of_origin"
      assert author.short_description == "some updated short_description"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Authors.update_author(author, @invalid_attrs)
      assert author == Authors.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Authors.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Authors.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Authors.change_author(author)
    end
  end
end
