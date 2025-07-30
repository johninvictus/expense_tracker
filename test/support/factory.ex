defmodule ExpenseTracker.Factory do
  @moduledoc """
  Module to generate test data
  """
  use ExMachina.Ecto, repo: ExpenseTracker.Repo

  def budget_factory do
    %ExpenseTracker.Tracker.Budget{
      name: "Test Budget",
      description: "This is a test budget",
      amount: Decimal.new("2000.00"),
      currency: "USD"
    }
  end

  def transaction_factory do
    date = Date.utc_today()

    %ExpenseTracker.Tracker.Transaction{
      type: "funding",
      amount: Money.new(:USD, "100.00"),
      occurred_at: date,
      budget: build(:budget),
      description: "Test transaction"
    }
  end
end
