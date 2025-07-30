defmodule ExpenseTrackerWeb.TransactionLive.FormComponent do
  use ExpenseTrackerWeb, :live_component

  alias ExpenseTracker.Tracker

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage transaction records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:amount_value]}
          type="number"
          label="Amount ($)"
          step="0.01"
          placeholder="$123.45"
          required
        />

        <.input field={@form[:occurred_at]} label="Date" type="date" required />
        <.input field={@form[:description]} type="text" label="Description" required />

        <.input field={@form[:notes]} type="text" label="Notes" placeholder="optional notes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Transaction</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{transaction: transactions} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Tracker.change_transaction(transactions))
     end)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset = Tracker.change_transaction(socket.assigns.transaction, transaction_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :edit, save_transaction) do
    save_transaction = Map.put(save_transaction, "budget_id", socket.assigns.budget_id)

    case Tracker.update_transaction(socket.assigns.transaction, save_transaction) do
      {:ok, transaction} ->
        notify_parent({:saved, transaction})

        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transaction(socket, :new, save_transaction) do
    save_transaction = Map.put(save_transaction, "budget_id", socket.assigns.budget_id)

    case Tracker.create_transaction(save_transaction) do
      {:ok, transaction} ->
        notify_parent({:saved, transaction})

        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
