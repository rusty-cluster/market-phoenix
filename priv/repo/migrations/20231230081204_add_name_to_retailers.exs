defmodule Market.Repo.Migrations.AddNameToRetailers do
  use Ecto.Migration

  def change do
    alter table(:retailers) do
      add :name, :string, null: false
    end
    create unique_index(:retailers, [:name])
  end
end
