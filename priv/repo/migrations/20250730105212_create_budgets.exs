defmodule ExpenseTracker.Repo.Migrations.CreateBudgets do
  use Ecto.Migration

  def up do
    create table(:budgets) do
      add :name, :string
      add :amount, :decimal
      add :currency, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create index(:budgets, [:currency])
    create index(:budgets, [:amount])
    create unique_index(:budgets, [:name])
  end

  def down do
    drop index(:budgets, [:currency])
    drop index(:budgets, [:amount])
    drop unique_index(:budgets, [:name])
    drop table(:budgets)
  end
end
