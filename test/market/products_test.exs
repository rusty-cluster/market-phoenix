defmodule Market.ProductsTest do
  use Market.DataCase

  alias Market.Products

  describe "products" do
    alias Market.Products.Product

    import Market.Factory

    @invalid_attrs %{description: nil, name: nil, price: nil, vendor_id: nil}

    test "list_products/0 returns all products" do
      product = insert(:product)
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = insert(:product)
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{description: "some description", name: "some name", price: 42, vendor_id: 42}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 42
      assert product.vendor_id == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = insert(:product)
      update_attrs = %{description: "some updated description", name: "some updated name", price: 43, vendor_id: 43}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 43
      assert product.vendor_id == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = insert(:product)
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = insert(:product)
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = insert(:product)
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
