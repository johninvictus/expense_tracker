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
      |> transaction_stream()
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
    socket =
      if transaction.occurred_at.month == socket.assigns.month and
           transaction.occurred_at.year == socket.assigns.year do
        socket
        |> stream_insert(:transactions, transaction)
        |> calculate_summary()
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "update_month_event",
        %{"month" => <<year::binary-size(4), "-", month::binary-size(2)>> = month_str},
        socket
      ) do
    month = String.to_integer(month)
    year = String.to_integer(year)

    socket =
      socket
      |> assign(:month, month)
      |> assign(:year, year)
      |> assign(:year_month_str, month_str)
      |> transaction_stream()
      |> calculate_summary()

    {:noreply, socket}
  end

  defp transaction_stream(socket) do
    stream(
      socket,
      :transactions,
      Tracker.list_transactions_by_budget_id_and_year_month(
        socket.assigns.budget_id,
        socket.assigns.year,
        socket.assigns.month
      ),
      reset: true
    )
  end

  defp calculate_summary(socket) do
    %{budget_id: budget_id, month: month, year: year} = socket.assigns

    summary = Tracker.budget_summary(budget_id, year, month)

    default = Money.new!("USD", 0)

    total_income = Map.get(summary, :total_income, default)
    total_expenses = Map.get(summary, :total_expenses, default)
    net_amount = Map.get(summary, :net_amount, default)
    budget_limit = Map.get(summary, :budget_limit, default)
    transaction_count = Map.get(summary, :transaction_count, 0)

    socket
    |> assign(:total_income, Money.to_string!(total_income))
    |> assign(:total_expenses, Money.to_string!(total_expenses))
    |> assign(:net_amount, Money.to_string!(net_amount))
    |> assign(:budget_limit, Money.to_string!(budget_limit))
    |> assign(:transaction_count, transaction_count)
  end
end
