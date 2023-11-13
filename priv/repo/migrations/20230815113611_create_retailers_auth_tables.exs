defmodule Market.Repo.Migrations.CreateRetailersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:retailers) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:retailers, [:email])

    create table(:retailers_tokens) do
      add :retailer_id, references(:retailers, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:retailers_tokens, [:retailer_id])
    create unique_index(:retailers_tokens, [:context, :token])
  end
end
