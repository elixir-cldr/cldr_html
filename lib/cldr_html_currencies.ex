if Cldr.Code.ensure_compiled?(Cldr.Currency) do
  defmodule Cldr.HTML.Currency do
    @moduledoc """
    Implements `Phoenix.HTML.Form.select/4` specifically for
    localised currency display.

    """

    @type select_options :: [
            {:currencies, [atom() | binary(), ...]}
            | {:locale, Cldr.Locale.locale_name() | Cldr.LanguageTag.t()}
            | {:collator, function()}
            | {:mapper, (Cldr.Currency.t() -> String.t())}
            | {:backend, module()}
            | {:selected, atom() | binary()}
          ]

    @doc """
    Generate an HTML select tag for a currency list
    that can be used with a `Phoenix.HTML.Form.t`.

    ## Arguments

    * A `Phoenix.HTML.Form.t()` form

    * A `Phoenix.HTML.Form.field()` field

    * A `Keyword.t()` list of options

    ## Options

    For select options see `Phoenix.HTML.Form.select/4`

    * `:currencies` defines the list of currencies to be
      displayed in the the `select` tag.  The list defaults to
      the currencies returned by `Money.known_tender_currencies/0`
      if the package [ex_money](https://hex.pm/packages/ex_money)
      is installed otherwise it is the list returned by
      `Cldr.known_currencies/0`

    * `:locale` defines the locale to be used to localise the
      description of the currencies.  The default is the locale
      returned by `Cldr.get_locale/1`

    * `:backend` is any backend module. The default is
      `Cldr.default_backend!/0`

    * `:collator` is a function used to sort the currencies
      in the selection list. It is passed a list of maps where
      each map represents a `t:Cldr.Currency`. The default collator
      sorts by `name_1 < name_2`. As a result, default collation
      sorts by code point which will not return expected results
      for scripts other than Latin.

    * `:mapper` is a function that creates the text to be
      displayed in the select tag for each currency.  It is
      passed the currency definition `t:Cldr.Currency` as returned by
      `Cldr.Currency.currency_for_code/2`.  The default function
      is `&({&1.code <> " - " <> &1.name, &1.code})`

    * `:selected` identifies the currency that is to be selected
      by default in the `select` tag.  The default is `nil`. This
      is passed unmodified to `Phoenix.HTML.Form.select/4`

    * `:prompt` is a prompt displayed at the top of the select
       box. This is passed unmodified to `Phoenix.HTML.Form.select/4`

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
      select(form, field, validate_options(options), options[:selected])
    end

    @doc """
    Generate a list of options for a currency list
    that can be used with `Phoenix.HTML.Form.select/4`,
    `Phoenix.HTML.Form.options_for_select/2` or
    to create a <datalist>.

    ## Arguments

    * A `Keyword.t()` list of options.

    ## Options

    See `Cldr.HTML.Currency.select/3` for options.

    """
    @spec currency_options(select_options) ::
            list(tuple())
            | {:error, {Cldr.UnknownCurrencyError, binary()}}
            | {:error, {Cldr.UnknownLocaleError, binary()}}

    def currency_options(options \\ [])

    def currency_options(options) when is_list(options) do
      options
      |> validate_options()
      |> build_currency_options()
    end

    # Invalid options
    defp select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # Selected currency
    @omit_from_select_options [:currencies, :locale, :mapper, :collator, :backend]
    defp select(form, field, options, _selected) do
      select_options =
        options
        |> Map.drop(@omit_from_select_options)
        |> Map.to_list()

      options = build_currency_options(options)

      Phoenix.HTML.Form.select(form, field, options, select_options)
    end

    defp validate_options(options) do
      options = Map.new(options)

      with options <- Map.merge(default_options(), options),
           {:ok, options} <- validate_locale(options),
           {:ok, options} <- validate_selected(options),
           {:ok, options} <- validate_currencies(options) do
        options
      end
    end

    defp default_options do
      Map.new(
        currencies: default_currency_list(),
        locale: Cldr.get_locale(),
        backend: nil,
        collator: &default_collator/1,
        mapper: &{&1.code <> " - " <> &1.name, &1.code},
        selected: nil
      )
    end

    defp default_collator(currencies) do
      Enum.sort(currencies, &default_comparator/2)
    end

    # Note that this is not a unicode aware comparison
    defp default_comparator(currency_1, currency_2) do
      currency_1.name < currency_2.name
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

    defp validate_locale(options) do
      {locale, backend} = Cldr.locale_and_backend_from(options[:locale], options[:backend])

      with {:ok, locale} <- Cldr.validate_locale(locale, backend) do
        options
        |> Map.put(:locale, locale)
        |> Map.put(:backend, locale.backend)
        |> wrap(:ok)
      end
    end

    defp wrap(term, atom) do
      {atom, term}
    end

    defp maybe_include_selected_currency(%{selected: nil} = options) do
      options
    end

    defp maybe_include_selected_currency(%{currencies: currencies, selected: selected} = options) do
      if Enum.any?(currencies, &(&1 == selected)) do
        options
      else
        Map.put(options, :currencies, [selected | currencies])
      end
    end

    defp build_currency_options(options) when is_map(options) do
      options = maybe_include_selected_currency(options)

      currencies = Map.fetch!(options, :currencies)
      collator = Map.fetch!(options, :collator)
      mapper = Map.fetch!(options, :mapper)
      backend = Map.fetch!(options, :backend)
      options = Map.to_list(options)

      currencies
      |> Enum.map(&(Cldr.Currency.currency_for_code(&1, backend, options) |> elem(1)))
      |> collator.()
      |> Enum.map(&mapper.(&1))
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
