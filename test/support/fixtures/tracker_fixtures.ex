defmodule ExpenseTracker.TrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExpenseTracker.Tracker` context.
  """

  @doc """
  Generate a budget.
  """
  def budget_fixture(attrs \\ %{}) do
    {:ok, budget} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        description: "some description",
        name: "some name"
      })
      |> ExpenseTracker.Tracker.create_budget()

    budget
  end
end
