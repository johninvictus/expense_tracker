defmodule ExpenseTracker.TrackerTest do
  use ExpenseTracker.DataCase

  alias ExpenseTracker.Tracker

  describe "budgets" do
    alias ExpenseTracker.Tracker.Budget

    import ExpenseTracker.TrackerFixtures

    @invalid_attrs %{name: nil, description: nil, amount: nil}

    test "list_budgets/0 returns all budgets" do
      budget = budget_fixture()
      assert Tracker.list_budgets() == [budget]
    end

    test "get_budget!/1 returns the budget with given id" do
      budget = budget_fixture()
      assert Tracker.get_budget!(budget.id) == budget
    end

    test "create_budget/1 with valid data creates a budget" do
      valid_attrs = %{name: "some name", description: "some description", amount: "120.5"}

      assert {:ok, %Budget{} = budget} = Tracker.create_budget(valid_attrs)
      assert budget.name == "some name"
      assert budget.description == "some description"
      assert budget.amount == Decimal.new("120.5")
    end

    test "create_budget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_budget(@invalid_attrs)
    end

    test "update_budget/2 with valid data updates the budget" do
      budget = budget_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        amount: "456.7"
      }

      assert {:ok, %Budget{} = budget} = Tracker.update_budget(budget, update_attrs)
      assert budget.name == "some updated name"
      assert budget.description == "some updated description"
      assert budget.amount == Decimal.new("456.7")
    end

    test "update_budget/2 with invalid data returns error changeset" do
      budget = budget_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_budget(budget, @invalid_attrs)
      assert budget == Tracker.get_budget!(budget.id)
    end

    test "delete_budget/1 deletes the budget" do
      budget = budget_fixture()
      assert {:ok, %Budget{}} = Tracker.delete_budget(budget)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_budget!(budget.id) end
    end

    test "change_budget/1 returns a budget changeset" do
      budget = budget_fixture()
      assert %Ecto.Changeset{} = Tracker.change_budget(budget)
    end
  end

  describe "transactions" do
    alias ExpenseTracker.Tracker.Transaction

    import ExpenseTracker.TrackerFixtures

    @invalid_attrs %{type: nil, amount_value: nil, occurred_at: nil, budget_id: nil, description: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Tracker.list_transactions() == [transaction]
    end
  end
end
