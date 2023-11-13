defmodule Market.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :vendor_id, references(:vendors, on_delete: :restrict), null: false
      add :retailer_id, references(:retailers, on_delete: :restrict), null: false
      add :status, :string, null: false
      add :total_price, :integer

      timestamps()
    end
  end
end
