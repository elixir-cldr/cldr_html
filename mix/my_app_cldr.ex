defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "th"],
    providers: [Cldr.Number, Cldr.Unit, Cldr.Territory, Cldr.LocaleDisplay]

end