defmodule Goodreads.SalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Goodreads.Sales` context.
  """

  @doc """
  Generate a sale.
  """
  def sale_fixture(attrs \\ %{}) do
    {:ok, sale} =
      attrs
      |> Enum.into(%{
        sales: 42,
        year: 42
      })
      |> Goodreads.Sales.create_sale()

    sale
  end
end
