defmodule Market.Retailer.Orders do
  import Ecto.Query, warn: false
  alias Market.Repo
  alias Market.Orders.Order

  def list_orders(retailer_id) do
    query = from(Order, where: [retailer_id: ^retailer_id])
    Repo.all(query)
  end

  def get_order!(retailer_id, id) do
    query = from(Order, where: [id: ^id, retailer_id: ^retailer_id])
    Repo.one!(query)
  end

  def create_order(retailer, attrs) do
    Ecto.build_assoc(retailer, :orders) |> change_order(attrs) |> Repo.insert()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end
