defmodule ExpenseTracker.Utils.DateUtils do
  @moduledoc """
   Will hold a date utils
  """
  @spec get_current_month :: String.t()
  def get_current_month(date \\ Date.utc_today()) do
    Calendar.strftime(date, "%Y-%m")
  end
end
