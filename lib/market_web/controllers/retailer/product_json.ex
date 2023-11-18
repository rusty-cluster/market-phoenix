defmodule MarketWeb.Retailer.ProductJSON do
  alias Market.Products.Product

  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      vendor_id: product.vendor_id,
      description: product.description,
      price: product.price
    }
  end
end
