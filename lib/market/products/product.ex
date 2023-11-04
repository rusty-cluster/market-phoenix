defmodule Market.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :name, :string
    field :price, :integer
    field :vendor_id, :integer

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :vendor_id, :description, :price])
    |> validate_required([:name, :vendor_id, :description, :price])
  end
end
