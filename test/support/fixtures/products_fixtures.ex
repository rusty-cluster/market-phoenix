defmodule Market.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Market.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: 42,
        vendor_id: 42
      })
      |> Market.Products.create_product()

    product
  end
end
