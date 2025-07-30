defmodule ExpenseTrackerWeb.TransactionLive.Index do
  @moduledoc """
  View transactions of a particular budget
  """
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Tracker
  alias ExpenseTracker.Tracker.Budget

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, stream(socket, :transactions, Tracker.list_transactions_by_budget_id(id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Budget")
    |> assign(:budget, Tracker.get_budget!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Budget")
    |> assign(:budget, %Budget{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:budget, nil)
  end

  @impl true
  def handle_info({ExpenseTrackerWeb.TransactionLive.FormComponent, {:saved, transaction}}, socket) do
    {:noreply, stream_insert(socket, :transactions, transaction)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Tracker.get_transaction!(id)
    {:ok, _} = Tracker.delete_transaction(transaction)

    {:noreply, stream_delete(socket, :transactions, transaction)}
  end
end
