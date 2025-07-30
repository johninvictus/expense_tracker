defmodule ExpenseTracker.Factories do
  @moduledoc """
  Module to generate test data
  """
  use ExMachina.Ecto, repo: ExpenseTracker.Repo

  def budget_factory do
    %ExpenseTracker.Tracker.Budget{
      name: "Test Budget",
      description: "This is a test budget",
      amount: Decimal.new("100.00"),
      currency: "USD"
    }
  end

  def transaction_factory do
    date = Date.utc_today()

    %ExpenseTracker.Tracker.Transaction{
      type: "funding",
      amount: Money.new(100, "USD"),
      occurred_at: date,
      budget: build(:budget),
      description: "Test transaction"
    }
  end
end
