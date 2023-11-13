defmodule MarketWeb.Retailer.OrderJSON do
  alias Market.Orders.Order

  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: data(order))}
  end

  def show(%{order: order}) do
    %{data: data(order)}
  end

  defp data(%Order{} = order) do
    %{
      id: order.id,
      vendor_id: order.vendor_id,
      retailer_id: order.retailer_id,
      total_price: order.total_price
    }
  end
end
