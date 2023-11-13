defmodule Market.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    belongs_to :vendor, Market.Accounts.Vendor
    belongs_to :retailer, Market.Accounts.Retailer

    field :total_price, :integer
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:vendor_id, :retailer_id, :total_price, :status])
    |> validate_required([:vendor_id, :retailer_id, :total_price, :status])
    |> assoc_constraint(:vendor)
    |> assoc_constraint(:retailer)
  end
end
