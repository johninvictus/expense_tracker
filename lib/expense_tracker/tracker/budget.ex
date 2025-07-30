defmodule ExpenseTracker.Tracker.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budgets" do
    field :name, :string
    field :description, :string
    field :amount, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :amount, :description])
    |> validate_required([:name, :amount, :description])
  end
end
