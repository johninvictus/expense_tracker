defmodule ExpenseTrackerWeb.TransactionLiveTest do
  @moduledoc false
  use ExpenseTrackerWeb.ConnCase

  import Phoenix.LiveViewTest

  defp create_transaction(_) do
    transaction = insert(:transaction)
    %{transaction: transaction}
  end

  describe "Index" do
    setup [:create_transaction]

    test "displays transaction", %{conn: conn, transaction: transaction} do
      {:ok, _index_live, html} = live(conn, ~p"/budgets/#{transaction.budget_id}/transactions")

      assert html =~ "Listing Transactions"
      assert html =~ transaction.description
      assert html =~ Money.to_string!(transaction.amount)
    end
  end
end
