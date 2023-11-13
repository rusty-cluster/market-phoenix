defmodule MarketWeb.Retailer.OrderControllerTest do
  use MarketWeb.ConnCase

  import Market.Factory

  alias Market.Orders.Order

  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    total_price: 43
  }
  @invalid_attrs %{description: nil, name: nil, price: nil, retailer_id: nil}

  setup :register_and_log_in_retailer

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), vendor: insert(:vendor)}
  end

  describe "index" do
    test "lists all orders", %{conn: conn} do
      conn = get(conn, ~p"/retailers/orders")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order" do
    test "renders order when data is valid", %{conn: conn, retailer: retailer, vendor: vendor} do
      order = params_for(:order, retailer: retailer, vendor: vendor)
      conn = post(conn, ~p"/retailers/orders", order: order)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/retailers/orders/#{id}")

      assert %{
               "id" => id,
               "total_price" => 420,
               "retailer_id" => retailer.id,
               "vendor_id" => vendor.id
             } == json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/retailers/orders", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order" do
    setup [:create_order]

    test "renders order when data is valid", %{conn: conn, order: %Order{id: id} = order} do
      conn = put(conn, ~p"/retailers/orders/#{order}", order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/retailers/orders/#{id}")

      assert %{
               "id" => ^id,
               "total_price" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      conn = put(conn, ~p"/retailers/orders/#{order}", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      conn = delete(conn, ~p"/retailers/orders/#{order}")
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, ~p"/retailers/orders/#{order}")
      end)
    end
  end

  defp create_order(%{retailer: retailer, vendor: vendor}) do
    %{order: insert(:order, retailer: retailer, vendor: vendor)}
  end
end
