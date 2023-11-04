defmodule Market.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    belongs_to :vendor, Market.Accounts.Vendor

    field :description, :string
    field :name, :string
    field :price, :integer

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :vendor_id, :description, :price])
    |> validate_required([:name, :vendor_id, :description, :price])
    |> assoc_constraint(:vendor)
    |> unique_constraint([:name, :vendor_id])
  end
end
