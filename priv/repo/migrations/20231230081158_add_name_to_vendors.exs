defmodule Market.Repo.Migrations.AddNameToVendors do
  use Ecto.Migration

  def change do
    alter table(:vendors) do
      add :name, :string, null: false
    end
    create unique_index(:vendors, [:name])
  end
end
