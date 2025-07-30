defmodule ExpenseTracker.Tracker.Budget do
  @moduledoc """
   Will hold a budget record
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          description: String.t(),
          amount: Money.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }
  schema "budgets" do
    field :name, :string
    field :description, :string
    field :amount, Money.Ecto.Composite.Type

    timestamps(type: :utc_datetime)
  end

  @required_field ~w(name amount description)a
  @optional_field ~w()a

  @doc false
  @spec changeset(budget :: t(), attrs :: map()) :: Ecto.Changeset.t()
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, @required_field ++ @optional_field)
    |> validate_required(@required_field)
    |> validate_amount()
  end

  defp validate_amount(%{valid?: false} = changeset), do: changeset

  defp validate_amount(changeset) do
    amount = get_field(changeset, :amount)

    if Money.compare(amount, Money.new(0, amount.currency)) in [:lt, :eq],
      do: add_error(changeset, :amount, "Amount must be greater than 0"),
      else: changeset
  end
end
