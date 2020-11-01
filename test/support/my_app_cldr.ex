defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "th"],
    providers: [Cldr.Number]

end