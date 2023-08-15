defmodule Market.Repo.Migrations.CreateVendorsAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:vendors) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:vendors, [:email])

    create table(:vendors_tokens) do
      add :vendor_id, references(:vendors, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:vendors_tokens, [:vendor_id])
    create unique_index(:vendors_tokens, [:context, :token])
  end
end
