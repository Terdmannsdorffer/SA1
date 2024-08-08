defmodule Goodreads.AuthorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Goodreads.Authors` context.
  """

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        country_of_origin: "some country_of_origin",
        date_of_birth: ~D[2024-08-07],
        name: "some name",
        short_description: "some short_description"
      })
      |> Goodreads.Authors.create_author()

    author
  end
end
