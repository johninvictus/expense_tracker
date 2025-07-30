defmodule ExpenseTracker.TransactionTest do
  use ExpenseTracker.DataCase

  alias ExpenseTracker.Tracker.Transaction

  test "changeset with valid attributes" do
    attrs = %{
      type: "funding",
      amount: Money.new(100, "USD"),
      occurred_at: Date.utc_today(),
      budget_id: 1,
      description: "Test transaction"
    }

    changeset = Transaction.changeset(%Transaction{}, attrs)

    assert changeset.valid?
  end

  test "Empty attributes" do
    changeset = Transaction.changeset(%Transaction{}, %{})
    assert errors_on(changeset)[:type] == ["can't be blank"]
    assert errors_on(changeset)[:amount] == ["can't be blank"]
    assert errors_on(changeset)[:occurred_at] == ["can't be blank"]
    assert errors_on(changeset)[:budget_id] == ["can't be blank"]
    assert errors_on(changeset)[:description] == ["can't be blank"]
  end

  test "Invalid amount" do
    changeset = Transaction.changeset(%Transaction{}, %{
      type: "funding",
      amount: Money.new(-1, "USD"),
      occurred_at: Date.utc_today(),
      budget_id: 1,
      description: "Test transaction"
    })
    assert errors_on(changeset)[:amount] == ["Amount must be greater than 0"]
  end

  test "Invalid occurred_at" do
    changeset = Transaction.changeset(%Transaction{}, %{
      type: "funding",
      amount: Money.new(100, "USD"),
      occurred_at: nil,
      budget_id: 1,
      description: "Test transaction"
    })
    assert errors_on(changeset)[:occurred_at] == ["can't be blank"]
  end
end
