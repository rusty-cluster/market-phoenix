defmodule Market.ProductsTest do
  use Market.DataCase

  alias Market.Products

  describe "products" do
    alias Market.Products.Product

    import Market.Factory

    @invalid_attrs %{description: nil, name: nil, price: nil, vendor_id: nil}

    test "list_products/0 returns all products" do
      vendor = insert(:vendor)
      product = insert(:product, vendor_id: vendor.id)
      assert Products.list_products(vendor.id) == [product]
    end

    test "get_product!/1 returns the product with given id" do
      vendor = insert(:vendor)
      product = insert(:product, vendor_id: vendor.id)

      assert Products.get_product!(vendor.id, product.id) == product
    end

    test "create_product/2 with valid data creates a product" do
      vendor = insert(:vendor)

      valid_attrs = %{
        description: "some description",
        name: "some name",
        price: 42
      }

      assert {:ok, %Product{} = product} = Products.create_product(vendor, valid_attrs)
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 42
      assert product.vendor_id == vendor.id
    end

    test "create_product/1 with invalid data returns error changeset" do
      vendor = insert(:vendor)
      assert {:error, %Ecto.Changeset{}} = Products.create_product(vendor, @invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      vendor = insert(:vendor)
      product = insert(:product, vendor: vendor)

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        price: 43
      }

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      vendor = insert(:vendor)
      product = insert(:product, vendor_id: vendor.id)

      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(vendor.id, product.id)
    end

    test "delete_product/1 deletes the product" do
      vendor = insert(:vendor)
      product = insert(:product, vendor: vendor)

      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(vendor.id, product.id) end
    end

    test "change_product/1 returns a product changeset" do
      vendor = insert(:vendor)
      product = insert(:product, vendor_id: vendor.id)
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
