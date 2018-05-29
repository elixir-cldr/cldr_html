defmodule Cldr.HTML do
  if Code.ensure_compiled?(Cldr.Currency) do
    defdelegate currency_select(form, field, options), to: Cldr.HTML.Currency, as: :select
  end
end
