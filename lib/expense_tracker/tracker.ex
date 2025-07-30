defmodule ExpenseTracker.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  alias ExpenseTracker.Repo

  alias ExpenseTracker.Tracker.Budget
  alias ExpenseTracker.Tracker.Transaction

  @doc """
  Returns the list of budgets.

  ## Examples

      iex> list_budgets()
      [%Budget{}, ...]

  """
  def list_budgets do
    Repo.all(Budget)
  end

  @doc """
  Gets a single budget.

  Raises `Ecto.NoResultsError` if the Budget does not exist.

  ## Examples

      iex> get_budget!(123)
      %Budget{}

      iex> get_budget!(456)
      ** (Ecto.NoResultsError)

  """
  def get_budget!(id), do: Repo.get!(Budget, id)

  @doc """
  Creates a budget.

  ## Examples

      iex> create_budget(%{field: value})
      {:ok, %Budget{}}

      iex> create_budget(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a budget.

  ## Examples

      iex> update_budget(budget, %{field: new_value})
      {:ok, %Budget{}}

      iex> update_budget(budget, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_budget(%Budget{} = budget, attrs) do
    budget
    |> Budget.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a budget.

  ## Examples

      iex> delete_budget(budget)
      {:ok, %Budget{}}

      iex> delete_budget(budget)
      {:error, %Ecto.Changeset{}}

  """
  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking budget changes.

  ## Examples

      iex> change_budget(budget)
      %Ecto.Changeset{data: %Budget{}}

  """
  def change_budget(%Budget{} = budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end

  @doc """
  Returns the list of transactions for a given budget.

  ## Examples

      iex> list_transactions_by_budget_id(1)
      [%Transaction{}, ...]

  """
  @spec list_transactions_by_budget_id(id :: integer()) :: [Transaction.t()]
  def list_transactions_by_budget_id(id) do
    Repo.all(from t in Transaction, where: t.budget_id == ^id)
  end

  @doc """
  Returns the list of transactions for a given budget within a year and month.

  ## Examples

      iex> list_transactions_by_budget_id_and_year_month(1, 2025, 1)
      [%Transaction{}, ...]

  """
  @spec list_transactions_by_budget_id_and_year_month(id :: integer(), year :: integer(), month :: integer()) :: [Transaction.t()]
  def list_transactions_by_budget_id_and_year_month(id, year, month) do
    base_query = from t in Transaction, where: t.budget_id == ^id

    query =
      from t in base_query,
        where:
          fragment("EXTRACT(year FROM ?)", t.occurred_at) == ^year and
            fragment("EXTRACT(month FROM ?)", t.occurred_at) == ^month

    Repo.all(query)
  end

  @doc """
  Returns the list of transactions for a given budget within a date range.

  ## Examples

      iex> list_transactions_by_budget_id_and_date_range(1, ~D[2025-01-01], ~D[2025-01-31])
      [%Transaction{}, ...]

  """
  @spec list_transactions_by_budget_id_and_date_range(
          id :: integer(),
          start_date :: Date.t(),
          end_date :: Date.t()
        ) :: [Transaction.t()]
  def list_transactions_by_budget_id_and_date_range(id, start_date, end_date) do
    Repo.all(
      from t in Transaction,
        where: t.budget_id == ^id and t.occurred_at >= ^start_date and t.occurred_at <= ^end_date,
        order_by: [desc: t.occurred_at]
    )
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get_transaction!(id :: integer()) :: Transaction.t()
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> change_transaction(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> change_transaction(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_transaction(transaction :: Transaction.t()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  @spec change_transaction(transaction :: Transaction.t(), attrs :: map()) :: Ecto.Changeset.t()
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
