defmodule ExpenseTracker.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def up do
    # description, amount, date, optional notes
    create table(:transactions) do
      add :type, :string, null: false
      add :description, :string, null: false

      add :amount, :money_with_currency, null: false
      add :occurred_at, :date, null: false
      add :notes, :string

      add :budget_id, references(:budgets, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:type])
    create index(:transactions, [:amount])
    create index(:transactions, [:occurred_at])
    create index(:transactions, [:budget_id])
  end

  def down do
    drop index(:transactions, [:type])
    drop index(:transactions, [:amount])
    drop index(:transactions, [:occurred_at])
    drop index(:transactions, [:budget_id])
    drop table(:transactions)
  end
end
