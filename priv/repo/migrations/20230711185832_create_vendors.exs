defmodule Market.Repo.Migrations.CreateVendors do
  use Ecto.Migration

  def change do
    create table(:vendors) do
      add :name, :string
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:vendors, :email)
  end
end
