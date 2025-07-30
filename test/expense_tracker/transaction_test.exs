defmodule ExpenseTracker.TransactionTest do
  @moduledoc false

  use ExpenseTracker.DataCase

  alias ExpenseTracker.Tracker.Transaction

  test "changeset with valid attributes" do
    attrs = %{
      type: "funding",
      amount_value: 100,
      occurred_at: Date.utc_today(),
      budget_id: 1,
      description: "Test transaction"
    }

    changeset = Transaction.changeset(%Transaction{}, attrs)

    assert changeset.valid?
  end

  test "Empty attributes" do
    changeset = Transaction.changeset(%Transaction{}, %{})

    assert errors_on(changeset)[:amount_value] == ["can't be blank"]
    assert errors_on(changeset)[:occurred_at] == ["can't be blank"]
    assert errors_on(changeset)[:budget_id] == ["can't be blank"]
    assert errors_on(changeset)[:description] == ["can't be blank"]
  end

  test "Invalid amount" do
    changeset =
      Transaction.changeset(%Transaction{}, %{
        type: "funding",
        amount_value: -1,
        occurred_at: Date.utc_today(),
        budget_id: 1,
        description: "Test transaction"
      })

    assert errors_on(changeset)[:amount_value] == ["Amount must be greater than 0"]
  end

  test "Invalid occurred_at" do
    changeset =
      Transaction.changeset(%Transaction{}, %{
        type: "funding",
        amount: Money.new(100, "USD"),
        occurred_at: nil,
        budget_id: 1,
        description: "Test transaction"
      })

    assert errors_on(changeset)[:occurred_at] == ["can't be blank"]
  end
end
