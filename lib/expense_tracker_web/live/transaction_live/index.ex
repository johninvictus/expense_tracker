defmodule ExpenseTrackerWeb.TransactionLive.Index do
  @moduledoc """
  View transactions of a particular budget
  """
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Tracker
  alias ExpenseTracker.Tracker.Transaction
  alias ExpenseTracker.Utils.DateUtils

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Set default date range: today as start, +30 days as end

    date_now = Date.utc_today()

    socket =
      socket
      |> assign(:budget_id, id)
      |> assign(:month, date_now.month)
      |> assign(:year, date_now.year)
      |> assign(:year_month_str, DateUtils.get_current_month(date_now))
      |> stream(
        :transactions,
        Tracker.list_transactions_by_budget_id_and_year_month(id, date_now.year, date_now.month)
      )
      |> calculate_summary()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Budget")
    |> assign(:transaction, Tracker.get_transaction!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, %Transaction{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_info(
        {ExpenseTrackerWeb.TransactionLive.FormComponent, {:saved, transaction}},
        socket
      ) do
    {:noreply, stream_insert(socket, :transactions, transaction)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Tracker.get_transaction!(id)
    {:ok, _} = Tracker.delete_transaction(transaction)

    {:noreply, stream_delete(socket, :transactions, transaction) |> calculate_summary()}
  end

  @impl true
  def handle_event("update_month", %{"value" => month}, socket) do
    IO.inspect(month, label: "month")

    # socket =
    #   socket
    #   |> assign(:month, month)
    #   |> calculate_summary()

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_start_date", %{"value" => start_date}, socket) do
    # Parse the start date and calculate end date (start + 30 days)
    case Date.from_iso8601(start_date) do
      {:ok, start_date_parsed} ->
        end_date = Date.add(start_date_parsed, 30)

        socket =
          socket
          |> assign(:start_date, start_date)
          |> assign(:end_date, Date.to_string(end_date))
          |> calculate_summary()

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp calculate_summary(socket) do
    %{budget_id: budget_id} = socket.assigns

    # Get budget and transactions
    budget = Tracker.get_budget!(budget_id)
    transactions = Tracker.list_transactions_by_budget_id(budget_id)

    # Calculate totals
    {total_income, total_expenses} =
      Enum.reduce(transactions, {Money.new(:USD, 0), Money.new(:USD, 0)}, fn transaction,
                                                                             {income, expenses} ->
        case transaction.type do
          :funding -> {Money.add!(income, transaction.amount), expenses}
          :spending -> {income, Money.add!(expenses, transaction.amount)}
          _ -> {income, expenses}
        end
      end)

    # Calculate net amount (income - expenses)
    negative_expenses = Money.mult!(total_expenses, -1)
    net_amount = Money.add!(total_income, negative_expenses)

    # Convert budget amount to Money for consistent formatting
    budget_limit = Money.new(budget.currency, budget.amount)

    socket
    |> assign(:total_income, Money.to_string!(total_income))
    |> assign(:total_expenses, Money.to_string!(total_expenses))
    |> assign(:net_amount, Money.to_string!(net_amount))
    |> assign(:budget_limit, Money.to_string!(budget_limit))
    |> assign(:transaction_count, length(transactions))

    # |> stream(:transactions, transactions, reset: true)
  end
end
