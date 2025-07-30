defmodule ExpenseTracker.Tracker.Transaction do
  @moduledoc """
   Will hold a transaction record
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpenseTracker.Tracker.Budget

  @type t :: %__MODULE__{
          id: integer(),
          type: :funding | :spending,
          description: String.t(),
          amount: Money.t(),
          occurred_at: Date.t(),
          notes: String.t() | nil,
          budget_id: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }
  schema "transactions" do
    field :type, Ecto.Enum, values: ~w(funding spending)a, default: :spending
    field :description, :string
    field :amount, Money.Ecto.Composite.Type
    field :occurred_at, :date
    field :notes, :string

    field :amount_value, :decimal, virtual: true

    belongs_to :budget, Budget

    timestamps(type: :utc_datetime)
  end

  @required_field ~w(type occurred_at budget_id description amount_value)a
  @optional_field ~w(notes)a

  @doc false
  @spec changeset(transaction :: t(), attrs :: map()) :: Ecto.Changeset.t()
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required_field ++ @optional_field)
    |> validate_required(@required_field)
    |> put_money_amount()
    |> put_virtual_amount_input()
    |> validate_amount()
    |> foreign_key_constraint(:budget_id)
  end

  defp validate_amount(%{valid?: false} = changeset), do: changeset

  defp validate_amount(changeset) do
    amount = get_field(changeset, :amount_value)

    if Decimal.compare(amount, Decimal.new(0)) in [:lt, :eq],
      do: add_error(changeset, :amount_value, "Amount must be greater than 0"),
      else: changeset
  end

  defp put_money_amount(%{valid?: true, changes: %{amount_value: amount}} = changeset) do
    put_change(changeset, :amount, Money.new(amount, :USD))
  end

  defp put_money_amount(changeset), do: changeset

  # Populate the virtual field from existing Money struct
  defp put_virtual_amount_input(%{changes: %{amount_value: amount}} = changeset)
       when not is_nil(amount) do
    changeset
  end

  defp put_virtual_amount_input(%{data: %{amount: %Money{amount: amount}}} = changeset) do
    put_change(changeset, :amount_value, amount)
  end

  defp put_virtual_amount_input(changeset), do: changeset
end
