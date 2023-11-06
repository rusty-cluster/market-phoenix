defmodule MarketWeb.Vendor.ProductControllerTest do
  use MarketWeb.ConnCase

  import Market.Factory

  alias Market.Products.Product

  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    price: 43
  }
  @invalid_attrs %{description: nil, name: nil, price: nil, vendor_id: nil}

  setup :register_and_log_in_vendor

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/vendors/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn, vendor: vendor} do
      product = params_for(:product, vendor: vendor)
      conn = post(conn, ~p"/vendors/products", product: product)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/vendors/products/#{id}")

      assert %{
               "id" => id,
               "description" => product.description,
               "name" => product.name,
               "price" => 42,
               "vendor_id" => vendor.id
             } == json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/vendors/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/vendors/products/#{product}", product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/vendors/products/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "name" => "some updated name",
               "price" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/vendors/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/vendors/products/#{product}")
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, ~p"/vendors/products/#{product}")
      end)
    end
  end

  defp create_product(%{vendor: vendor}) do
    %{product: insert(:product, vendor: vendor)}
  end
end
