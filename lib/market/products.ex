defmodule Market.Products do
  import Ecto.Query, warn: false
  alias Market.Repo
  alias Market.Products.Product

  def list_products(vendor_id) do
    query = from(Product, where: [vendor_id: ^vendor_id])
    Repo.all(query)
  end

  def get_product!(vendor_id, id) do
    query = from(Product, where: [id: ^id, vendor_id: ^vendor_id])
    Repo.one!(query)
  end

  def create_product(vendor, attrs) do
    Ecto.build_assoc(vendor, :products) |> change_product(attrs) |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
