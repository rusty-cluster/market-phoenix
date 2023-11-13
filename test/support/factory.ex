defmodule Market.Factory do
  use ExMachina.Ecto, repo: Market.Repo

  def vendor_factory do
    %Market.Accounts.Vendor{
      email: Faker.Internet.email(),
      hashed_password: "qwerty"
    }
  end

  def retailer_factory do
    %Market.Accounts.Retailer{
      email: Faker.Internet.email(),
      hashed_password: "qwerty"
    }
  end

  def product_factory do
    %Market.Products.Product{
      name: Faker.Cannabis.strain(),
      price: 42,
      description: Faker.Cannabis.health_benefit()
    }
  end

  def order_factory do
    %Market.Orders.Order{
      total_price: 420,
      status: "new"
    }
  end
end
