defmodule Cldr.HTML do
  if Code.ensure_compiled?(Cldr.Currency) do
    @type currency_select_options :: [{:currencies, list(atom() | binary())} | {:mapper, function()} | {:locale, String.t() | Cldr.LanguageTag.t()}]

    @doc """
    Genereate a currency select for a `Phoenix.HTML.Form.t`
    for select options see `Phoenix.HTML.Form.select/4`

    * `Options` are expected to be an `Keyword.t` with the following keys
      * `:currencies` defaults to `Cldr.known_currencies/1`
      * `:mapper`     defaults to `&({&1.code <> " - " <> &1.name, &1.code})`
      * `:locale`     defaults to `Cldr.default_locale/1`

    # Examples

       => Money.currency_select(my_form, :currency, [selected: :USD])
       => Money.currency_select(my_form, :currency, [selected: "USD"], ["USD", "EUR", :JPY], &({&1.code <> " - " <> &1.name, &1.code}))

    """
    @spec currency_select(Phoenix.HTML.Form.t, atom() | binary(), list(), currency_select_options) :: Phoenix.HTML.safe()
    def currency_select(form, field, select_options \\ [], options \\ [])
    def currency_select(form, field, select_options, options) do
      options = default_options(options)
      Phoenix.HTML.Form.select(form, field, currency_options(options), select_options)
    end

    defp default_options(options) do
      options
      |> Keyword.put_new(:currencies, Cldr.known_currencies())
      |> Keyword.put_new(:mapper, &({&1.code <> " - " <> &1.name, &1.code}))
      |> Keyword.put_new(:locale, Cldr.default_locale())
    end

    defp currency_options([[currencies: currencies, mapper: mapper, locale: locale] | _rest]) do
      currencies
      |> Enum.map(&Cldr.Currency.currency_for_code(&1, locale))
      |> Enum.map(fn {:ok, currency} -> mapper.(currency) end)
      |> Enum.sort()
    end
  end

end