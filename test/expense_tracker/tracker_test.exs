defmodule ExpenseTracker.TrackerTest do
  use ExpenseTracker.DataCase

  alias ExpenseTracker.Tracker
  alias ExpenseTracker.Repo

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

    test "budget_summary/3 returns a budget summary" do
      budget = insert(:budget)
      insert(:transaction, budget: budget)

      summary = Tracker.budget_summary(budget.id, Date.utc_today().year, Date.utc_today().month)

      assert summary.budget_id == budget.id
      assert summary.budget_limit == Money.new(:USD, "2000.00")
      assert summary.currency == "USD"
      assert summary.total_funding == Decimal.new("100.00")
      assert summary.total_spending == Decimal.new("0")
      assert summary.transaction_count == 1
    end
  end

  describe "transactions" do
    alias ExpenseTracker.Tracker.Transaction

    test "list_transactions_by_budget_id/1 returns all transactions for a given budget" do
      transaction = insert(:transaction)

      assert transaction.budget_id
             |> Tracker.list_transactions_by_budget_id()
             |> Repo.preload(:budget) == [transaction]
    end

    test "list_transactions_by_budget_id_and_year_month/3 returns all transactions for a given budget within a year and month" do
      transaction = insert(:transaction)

      assert transaction.budget_id
             |> Tracker.list_transactions_by_budget_id_and_year_month(
               transaction.occurred_at.year,
               transaction.occurred_at.month
             )
             |> Repo.preload(:budget) == [transaction]

      previous_month = transaction.occurred_at.month - 1

      previous_month =
        if previous_month < 1, do: 12, else: previous_month

      assert transaction.budget_id
             |> Tracker.list_transactions_by_budget_id_and_year_month(
               transaction.occurred_at.year,
               previous_month
             ) == []
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = insert(:transaction)
      assert transaction.id |> Tracker.get_transaction!() |> Repo.preload(:budget) == transaction

      assert_raise Ecto.NoResultsError, fn -> Tracker.get_transaction!(transaction.id + 123) end
    end

    test "create_transaction/1 with valid data creates a transaction" do
      budget = insert(:budget)

      valid_attrs = %{
        type: :funding,
        amount_value: 100,
        occurred_at: Date.utc_today(),
        budget_id: budget.id,
        description: "Test transaction"
      }

      assert {:ok, %Transaction{} = transaction} = Tracker.create_transaction(valid_attrs)
      assert transaction.type == :funding
      assert transaction.amount_value == Decimal.new("100")
      assert transaction.occurred_at == valid_attrs.occurred_at
      assert transaction.budget_id == budget.id
      assert transaction.description == "Test transaction"
      assert transaction.amount == Money.new(100, "USD")
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_transaction(%{})
    end

    test "change_transaction/2 returns a transaction changeset" do
      %{amount: %Money{amount: amount}} = params = params_for(:transaction)

      assert %Ecto.Changeset{} =
               Tracker.change_transaction(%Transaction{}, Map.put(params, :amount_value, amount))
    end
  end
end
