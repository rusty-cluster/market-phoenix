defmodule MarketWeb.Retailer.ProductControllerTest do
  use MarketWeb.ConnCase

  import Market.Factory

  setup :register_and_log_in_retailer

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      insert_list(2, :product, vendor: insert(:vendor))

      conn = get(conn, ~p"/retailers/products")
      assert length(json_response(conn, 200)["data"]) == 2
    end
  end

  describe "show product" do
    test "renders product", %{conn: conn} do
      vendor = insert(:vendor)
      product = insert(:product, vendor: vendor)

      conn = get(conn, ~p"/retailers/products/#{product.id}")

      assert %{
               "id" => product.id,
               "description" => product.description,
               "name" => product.name,
               "price" => product.price,
               "vendor_id" => vendor.id
             } == json_response(conn, 200)["data"]
    end
  end
end
