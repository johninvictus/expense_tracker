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
          amount: :decimal,
          currency: :string,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }
  schema "budgets" do
    field :name, :string
    field :description, :string

    field :amount, :decimal
    field :currency, :string, default: "USD"

    timestamps(type: :utc_datetime)
  end

  @required_field ~w(name amount description)a
  @optional_field ~w(currency)a

  @doc false
  @spec changeset(budget :: t(), attrs :: map()) :: Ecto.Changeset.t()
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, @required_field ++ @optional_field)
    |> validate_required(@required_field)
    |> validate_inclusion(:currency, ["USD", "EUR", "GBP"])
    |> validate_amount()
    |> unsafe_validate_unique(:name, ExpenseTracker.Repo)
    |> unique_constraint(:name)
  end

  defp validate_amount(%{valid?: false} = changeset), do: changeset

  defp validate_amount(changeset) do
    amount = get_field(changeset, :amount)

    if Decimal.compare(amount, Decimal.new(0)) in [:lt, :eq],
      do: add_error(changeset, :amount, "Amount must be greater than 0"),
      else: changeset
  end
end
