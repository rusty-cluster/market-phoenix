defmodule MarketWeb.Retailer.ProductController do
  use MarketWeb, :controller

  alias Market.Products

  action_fallback MarketWeb.FallbackController

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, :index, products: products)
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, :show, product: product)
  end
end
