defmodule Market.Vendor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vendors" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
