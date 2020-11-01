defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "th"],
    providers: [Cldr.Number, Cldr.Currency]

end