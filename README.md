# Cldr HTML

`Phoenix.HTML.Form.select/4` helper functions for CLDR. The functions in this library produce localised selection tags for HTML forms for:

* Currencies
* Units
* Territories
* Locales

## Usage

* `Cldr.HTML.Currency.select/3`. By default the currencies of the locales configured in the default backend. See also the documentation for [ex_cldr_currencies](https://hexdocs.pm/ex_cldr_currencies).

* `Cldr.HTML.Unit.select/3`. By default the units returned by `Cldr.Unit.known_units/0`. See also the documentation for [ex_cldr_units](https://hexdocs.pm/ex_cldr_units).

* `Cldr.HTML.Territory.select/3`. By default the territories returned by `Cldr.known_territories/0`. See also the documentation for [ex_cldr_territories](https://hexdocs.pm/ex_cldr_territories)

* `Cldr.HTML.Locale.select/3`. By default the list of locales known to `Cldr.default_backend!/0`. See also the documentation for [ex_cldr_locale_display](https://hexdocs.pm/ex_cldr_locale_display).

* [Not Yet Implemented] Select days of the week and months of the year in a given locale.

## Currency selection

```elixir
iex> Cldr.HTML.Currency.select(:my_form, :currency, selected: :USD, currencies: ~w(usd eur jpy cop)) |> Phoenix.HTML.safe_to_string()
```
Produces, when formatted:
```html
<select id="my_form_currency" name="my_form[currency]">
	<option value="COP">COP - Colombian Peso</option>
	<option value="EUR">EUR - Euro</option>
	<option value="JPY">JPY - Japanese Yen</option>
	<option value="USD" selected>USD - US Dollar</option>
</select>
```

## Unit selection

```elixir
iex> Cldr.HTML.Unit.select(:my_form, :units) |> Phoenix.HTML.safe_to_string()
```
Produces, when formatted:
```html
<select id=my_form_units name=my_form[units]>
	<option value=acre>acres</option>
	<option value=acre_foot>acre-feet</option>
	<option value=ampere>amperes</option>
	<option value=arc_minute>arcminutes</option>
	<option value=arc_second>arcseconds</option>
	<option value=astronomical_unit>astronomical units</option>
	<option value=atmosphere>atmospheres</option>
	<option value=bar>bars</option>
	<option value=barrel>barrels</option>
	<option value=bit>bits</option>
	<option value=british_thermal_unit>British thermal units</option>
	<option value=bushel>bushels</option>
	<option value=byte>bytes</option>
	<option value=calorie>calories</option>
	<option value=candela>candela</option>
	<option value=carat>carats</option>
	<option value=celsius>degrees Celsius</option>
    ....
</select>
```

## Territory selection

```elixir
iex> Cldr.HTML.Territory.select(:my_form, :territory, territories: [:US, :AU, :JP]) |> Phoenix.HTML.safe_to_string()
```
Produces, when formatted:
```html
<select id="my_form_territory" name="my_form[territory]">
	<option value="AU">🇦🇺 Australia</option>
	<option value="JP">🇯🇵 Japan</option>
	<option value="US">🇺🇸 United States</option>
</select>
```
## Locale selection

```elixir
# Select from the locales configured in `Cldr.default_backend/0` and localize them
# using the locale `Cldr.default_locale/0`
iex> Cldr.HTML.Locale.select(:my_form, :locales) |> Phoenix.HTML.safe_to_string()
```
Produces, when formatted:
```html
<select id="my_form_locales" name="my_form[locales]">
	<option value="ar">Arabic</option>
	<option value="zh-Hans">Chinese (Simplified)</option>
	<option value="zh-Hant">Chinese (Traditional)</option>
	<option value="en">English</option>
	<option value="he">Hebrew</option>
	<option value="th">Thai</option>
</select>
```

```elixir
# Select from the locales configured in `Cldr.default_backend/0` and localize them
# using their own locale`
iex> Cldr.HTML.Locale.select(:my_form, :locales, locale: :identity) |> Phoenix.HTML.safe_to_string()
```
Produces, when formatted:
```html
<select id="my_form_locales" name="my_form[locales]">
	<option value="en">English</option>
	<option value="he">עברית</option>
	<option value="ar">العربية</option>
	<option value="th">ไทย</option>
	<option value="zh-Hans">简体中文</option>
	<option value="zh-Hant">繁體中文</option>
</select>
```

## Installation

`Cldr.HTML` can be installed by adding `cldr_html` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cldr_html, "~> 0.6"}
  ]
end
```
The documentation can be found at [https://hexdocs.pm/cldr_html](https://hexdocs.pm/cldr_html).

## Configuration

The available functions depends on the configured dependencies in `mix.exs`:

For `Cldr.HTML.Currency.select/3`:

    {:ex_cldr_currencies, "~> 2.11"},

For `Cldr.HTML.Unit.select/3`:

    {:ex_cldr_units, "~> 3.7"},

For `Cldr.HTML.Locale.select/3`:

    {:ex_cldr_locale_display, "~> 1.0"},

For `Cldr.HTML.Territory.select/3`:

    {:ex_cldr_territories, "~> 2.2"},