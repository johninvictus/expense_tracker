defmodule ExpenseTrackerWeb.BudgetLive.Index do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Tracker
  alias ExpenseTracker.Tracker.Budget

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :budgets, Tracker.list_budgets())}
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
    |> assign(:page_title, "Listing Budgets")
    |> assign(:budget, nil)
  end

  @impl true
  def handle_info({ExpenseTrackerWeb.BudgetLive.FormComponent, {:saved, budget}}, socket) do
    {:noreply, stream_insert(socket, :budgets, budget)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    budget = Tracker.get_budget!(id)
    {:ok, _} = Tracker.delete_budget(budget)

    {:noreply, stream_delete(socket, :budgets, budget)}
  end
end
