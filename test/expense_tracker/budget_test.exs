defmodule ExpenseTracker.BudgetTest do
  use ExpenseTracker.DataCase

  alias ExpenseTracker.Tracker.Budget

  test "validates required fields - empty fields" do
    changeset = Budget.changeset(%Budget{}, %{})

    assert errors_on(changeset)[:name] == ["can't be blank"]
    assert errors_on(changeset)[:amount] == ["can't be blank"]
    assert errors_on(changeset)[:description] == ["can't be blank"]
  end

  test "test amount validation - amount less than 0" do
    changeset =
      Budget.changeset(%Budget{}, %{
        name: "Test",
        amount: Money.new!(-1, "USD"),
        description: "Test"
      })

    assert errors_on(changeset)[:amount] == ["Amount must be greater than 0"]
  end

  test "test amount validation - amount equal to 0" do
    changeset =
      Budget.changeset(%Budget{}, %{
        name: "Test",
        amount: Money.new!(0, "USD"),
        description: "Test"
      })

    assert errors_on(changeset)[:amount] == ["Amount must be greater than 0"]
  end
end
