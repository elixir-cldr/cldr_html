# Cldr.HTML

HTML helper functions for CLDR.

# Usage

* Select territories - by default using the territories where the configured locales are in use.

* Select currencies - by default the currencies of the locales currently configured

* Select languages - by default using the configured locales

* Select days of the week and months of the year in a given locale

## Examples

```elixir
  iex> import Phoenix.HTML
  iex> safe_to_string Cldr.HTML.Currency.select(:my_form, :currency, selected: :USD, currencies: ~w(usd eur jpy cop))
  "<select id=\"my_form_currency\" name=\"my_form[currency]\" selected=\"USD\"><option value=\"COP\">COP - Colombian Peso</option><option value=\"EUR\">EUR - Euro</option><option value=\"JPY\">JPY - Japanese Yen</option><option value=\"USD\">USD - US Dollar</option></select>"
```

## Installation

`Cldr.HTML` can be installed by adding `ex_cldr_html` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_cldr_html, "~> 0.1.0"}
  ]
end
```
The documentations can be found at [https://hexdocs.pm/cldr_html](https://hexdocs.pm/cldr_html).

