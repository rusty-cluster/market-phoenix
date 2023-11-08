defmodule MarketWeb.Vendor.ProductController do
  use MarketWeb, :controller

  alias Market.Products
  alias Market.Products.Product

  action_fallback MarketWeb.FallbackController

  def index(conn, _params) do
    products = Products.list_products(vendor(conn).id)
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Products.create_product(vendor(conn), product_params) do
      conn
      |> put_status(:created)
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(vendor(conn).id, id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(vendor(conn).id, id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(vendor(conn).id, id)

    with {:ok, %Product{}} <- Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end

  defp vendor(conn) do
    conn.assigns[:current_vendor]
  end
end
