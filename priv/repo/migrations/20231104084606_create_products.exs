defmodule Market.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :vendor_id, :integer
      add :description, :text
      add :price, :integer

      timestamps()
    end
  end
end
