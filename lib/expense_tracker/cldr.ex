defmodule ExpenseTracker.Cldr do
  @moduledoc """
  Configuring locales to support localised formatting
  """
  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Money]
end
