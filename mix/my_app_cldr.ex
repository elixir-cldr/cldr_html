defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "th", "zh-Hant", "zh-Hans", "ar", "he"],
    providers: [Cldr.Number, Cldr.Unit, Cldr.Territory, Cldr.LocaleDisplay]

end