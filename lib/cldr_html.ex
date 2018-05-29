defmodule Cldr.HTML do
  @moduledoc """
  Implements `Phoenix.HTML.Form.select/4` specifically
  for localized display of [Cldr](https://hex.pm/packages/ex_cldr)-based data.

  """

  if Code.ensure_compiled?(Cldr.Currency) do
    defdelegate currency_select(form, field, options), to: Cldr.HTML.Currency, as: :select
  end
end
