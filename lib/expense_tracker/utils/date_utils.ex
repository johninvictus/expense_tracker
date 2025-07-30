defmodule ExpenseTracker.Utils.DateUtils do

  @spec get_current_month :: String.t()
  def get_current_month do
    Calendar.strftime(Date.utc_today(), "%Y-%m")
  end
end
