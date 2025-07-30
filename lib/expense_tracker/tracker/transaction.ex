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
    field :type, Ecto.Enum, values: ~w(funding spending)a
    field :description, :string
    field :amount, Money.Ecto.Composite.Type
    field :occurred_at, :date
    field :notes, :string

    belongs_to :budget, Budget

    timestamps(type: :utc_datetime)
  end

  @required_field ~w(type amount occurred_at budget_id description)a
  @optional_field ~w(notes)a

  @doc false
  @spec changeset(transaction :: t(), attrs :: map()) :: Ecto.Changeset.t()
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required_field ++ @optional_field)
    |> validate_required(@required_field)
    |> validate_amount()
    |> foreign_key_constraint(:budget_id)
  end

  defp validate_amount(%{valid?: false} = changeset), do: changeset

  defp validate_amount(changeset) do
    amount = get_field(changeset, :amount)

    if Money.compare(amount, Money.new(0, amount.currency)) in [:lt, :eq],
      do: add_error(changeset, :amount, "Amount must be greater than 0"),
      else: changeset
  end
end
