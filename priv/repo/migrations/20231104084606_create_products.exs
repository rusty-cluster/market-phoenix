defmodule Market.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :vendor_id, references(:vendors, on_delete: :delete_all), null: false
      add :name, :string
      add :description, :text
      add :price, :integer

      timestamps()
    end
  end
end
