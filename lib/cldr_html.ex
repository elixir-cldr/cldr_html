defmodule Cldr.HTML do
  @moduledoc """
  Implements `Phoenix.HTML.Form.select/4` specifically
  for localized display of [Cldr](https://hex.pm/packages/ex_cldr)-based data.

  """

  if match?({:module, _}, Code.ensure_compiled(Cldr.Currency)) do
    defdelegate currency_select(form, field, options), to: Cldr.HTML.Currency, as: :select
    defdelegate currency_options(options), to: Cldr.HTML.Currency, as: :currency_options
  end

  if match?({:module, _}, Code.ensure_compiled(Cldr.Unit)) do
    defdelegate unit_select(form, field, options), to: Cldr.HTML.Unit, as: :select
    defdelegate unit_options(options), to: Cldr.HTML.Unit, as: :unit_options
  end

  if match?({:module, _}, Code.ensure_compiled(Cldr.Territory)) do
    defdelegate territory_select(form, field, options), to: Cldr.HTML.Territory, as: :select
    defdelegate territory_options(options), to: Cldr.HTML.Territory, as: :territory_options
  end

  if match?({:module, _}, Code.ensure_compiled(Cldr.LocaleDisplay)) do
    defdelegate locale_select(form, field, options), to: Cldr.HTML.Locale, as: :select
    defdelegate locale_options(options), to: Cldr.HTML.Locale, as: :locale_options
  end
end
