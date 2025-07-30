alias ExpenseTracker.Tracker


{:ok, budget_1} = Tracker.create_budget(%{
  name: "Budget 1",
  amount: 1000,
  currency: "USD",
  description: "Description 1"
})

{:ok, budget_2} = Tracker.create_budget(%{
  name: "Budget 2",
  amount: 2000,
  currency: "USD",
  description: "Description 2"
})


for i <- 1..5 do
  {:ok, _} = Tracker.create_transaction(%{
    budget_id: budget_1.id,
    type: "spending",
    description: "Description #{i}",
    amount_value: 100,
    occurred_at: DateTime.utc_now() |> DateTime.to_date(),
    notes: "Notes #{i}"
  })
end

for i <- 1..5 do
  {:ok, _} = Tracker.create_transaction(%{
    budget_id: budget_2.id,
    type: "spending",
    description: "Description #{i}",
    amount_value: 100,
    occurred_at: DateTime.utc_now() |> DateTime.to_date(),
    notes: "Notes #{i}"
  })
end
