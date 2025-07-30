defmodule ExpenseTrackerWeb.BudgetLive.FormComponent do
  use ExpenseTrackerWeb, :live_component

  alias ExpenseTracker.Tracker

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage budget records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="budget-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Budget</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{budget: budget} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Tracker.change_budget(budget))
     end)}
  end

  @impl true
  def handle_event("validate", %{"budget" => budget_params}, socket) do
    changeset = Tracker.change_budget(socket.assigns.budget, budget_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"budget" => budget_params}, socket) do
    save_budget(socket, socket.assigns.action, budget_params)
  end

  defp save_budget(socket, :edit, budget_params) do
    case Tracker.update_budget(socket.assigns.budget, budget_params) do
      {:ok, budget} ->
        notify_parent({:saved, budget})

        {:noreply,
         socket
         |> put_flash(:info, "Budget updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_budget(socket, :new, budget_params) do
    case Tracker.create_budget(budget_params) do
      {:ok, budget} ->
        notify_parent({:saved, budget})

        {:noreply,
         socket
         |> put_flash(:info, "Budget created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
