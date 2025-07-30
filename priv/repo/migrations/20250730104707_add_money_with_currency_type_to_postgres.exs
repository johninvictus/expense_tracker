defmodule ExpenseTracker.Repo.Migrations.AddMoneyWithCurrencyTypeToPostgres do
  @moduledoc """
   Postgres type to hold currency
  """
  use Ecto.Migration

  def up do
    execute("CREATE TYPE public.money_with_currency AS (currency_code varchar, amount numeric);")
  end

  def down do
    execute("DROP TYPE public.money_with_currency;")
  end
end
