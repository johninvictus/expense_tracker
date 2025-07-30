defmodule ExpenseTracker.Repo.Migrations.CreateBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets) do
      add :name, :string
      add :amount, :money_with_currency
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
