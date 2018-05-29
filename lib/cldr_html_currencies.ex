if Code.ensure_compiled?(Cldr.Currency) do
  defmodule Cldr.HTML.Currency do
    @moduledoc """
    Implements `Phoenix.HTML.Form.select/4` specifically for
    localised currency display.

    """

    @type select_options :: [
            {:currencies, [atom() | binary(), ...]}
            | {:locale, binary() | Cldr.LanguageTag.t()}
            | {:mapper, function()}
            | {:selected, atom() | binary()}
          ]

    @doc """
    Generate an HTML select tag for a currency list
    that can be used with a`Phoenix.HTML.Form.t`.

    ## Arguments

    * A `Phoenix.HTML.Form.t()` form

    * A `Phoenix.HTML.Form.field()` field

    * A `Keyword.t` list of options

    ## Options

    For select options see `Phoenix.HTML.Form.select/4`

    * `:currencies` defines the list of currencies to be
      displayed in the the `select` tag.  The list defaults to
      the currencies returned by `Money.known_tender_currencies/0`
      if the package [ex_money](https://hex.pm/packages/ex_money)
      is installed otherwise it is the list returned by
      `Cldr.known_currencies/1`

    * `:locale` defines the locale to be used to localise the
      description of the currencies.  The default is the locale
      returned by `Cldr.default_locale/1`

    * `:mapper` is a function that creates the text to be
      displayed in the select tag for each currency.  It is
      passed the currency definition `Cldr.Currency.t` as returned by
      `Cldr.Currency.currency_for_code/2`.  The default function
      is `&({&1.code <> " - " <> &1.name, &1.code})`

    * `:selected` identifies the currency that is to be selected
      by default in the `select` tag.  The default is `nil`.

    # Examples

         => Cldr.HTML.Currency.select(:my_form, :currency, selected: :USD)
         => Cldr.HTML.Currency.select(:my_form, :currency, currencies: ["USD", "EUR", :JPY], mapper: &({&1.name, &1.code}))

    """
    @spec select(
            form :: Phoenix.HTML.Form.t(),
            field :: Phoenix.HTML.Form.field(),
            select_options
          ) ::
            Phoenix.HTML.safe()
            | {:error, {Cldr.UnknownCurrencyError, binary()}}
            | {:error, {Cldr.UnknownLocaleError, binary()}}

    def select(form, field, options \\ [])

    def select(form, field, options) when is_list(options) do
      select(form, field, Map.new(options))
    end

    def select(form, field, %{} = options) do
      select(form, field, validate_options(options), options[:selected])
    end

    # Invalid options
    defp select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # No selected currency
    defp select(form, field, options, nil) do
      Phoenix.HTML.Form.select(form, field, currency_options(options))
    end

    # Selected currency
    defp select(form, field, options, selected) do
      options = maybe_include_selected_currency(options)
      Phoenix.HTML.Form.select(form, field, currency_options(options), selected: selected)
    end

    defp validate_options(options) do
      with options <- Map.merge(default_options(), options),
           {:ok, options} <- validate_selected(options),
           {:ok, options} <- validate_currencies(options),
           {:ok, options} <- validate_locale(options) do
        options
      end
    end

    defp default_options do
      Map.new(
        currencies: default_currency_list(),
        locale: Cldr.default_locale(),
        mapper: &{&1.code <> " - " <> &1.name, &1.code},
        selected: nil
      )
    end

    defp validate_selected(%{selected: nil} = options) do
      {:ok, options}
    end

    defp validate_selected(%{selected: selected} = options) do
      with {:ok, currency} <- Cldr.validate_currency(selected) do
        {:ok, Map.put(options, :selected, currency)}
      end
    end

    # Return a list of validated currencies or an error
    defp validate_currencies(%{currencies: currencies} = options) do
      validate_currencies(currencies, options)
    end

    defp validate_currencies(currencies) when is_list(currencies) do
      Enum.reduce_while(currencies, [], fn currency, acc ->
        case Cldr.validate_currency(currency) do
          {:ok, currency} -> {:cont, [currency | acc]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp validate_currencies(currencies, options) do
      case validate_currencies(currencies) do
        {:error, reason} -> {:error, reason}
        currencies -> {:ok, Map.put(options, :currencies, Enum.reverse(currencies))}
      end
    end

    defp validate_locale(%{locale: locale} = options) do
      with {:ok, locale} <- Cldr.validate_locale(locale) do
        {:ok, Map.put(options, :locale, locale)}
      end
    end

    defp maybe_include_selected_currency(%{currencies: currencies, selected: selected} = options) do
      if Enum.any?(currencies, &(&1 == selected)) do
        options
      else
        Map.put(options, :currencies, [selected | currencies])
      end
    end

    defp currency_options(options) do
      options[:currencies]
      |> Enum.map(&Cldr.Currency.currency_for_code(&1, options[:locale]))
      |> Enum.map(fn {:ok, currency} -> options[:mapper].(currency) end)
      |> Enum.sort()
    end

    # Default currency list to legal tender currencies
    # if Money is available, otherwise the full list of
    # Cldr currencies (which is almost identitical to ISO4217)
    if Code.ensure_loaded?(Money) do
      defp default_currency_list() do
        Money.known_tender_currencies()
      end
    else
      defp default_currency_list() do
        Cldr.known_currencies()
      end
    end
  end
end
