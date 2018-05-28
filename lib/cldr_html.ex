defmodule Cldr.Html do
  if Code.ensure_compiled?(Cldr.Currency) do
    @type currency_select_options :: [
                                       {:currencies, [atom() | binary(), ...]}
                                       | {:locale, binary() | Cldr.LanguageTag.t()}
                                       | {:mapper, function()}
                                       | {:selected, atom() | binary()}
                                      ]

    @doc """
    Genereate a currency select for a `Phoenix.HTML.Form.t`
    for select options see `Phoenix.HTML.Form.select/4`

    * `Options` are expected to be an `Keyword.t` with the following keys
      * `:currencies` defaults to `Cldr.known_currencies/1`
      * `:locale`     defaults to `Cldr.default_locale/1`
      * `:mapper`     defaults to `&({&1.code <> " - " <> &1.name, &1.code})`
      * `:selected    defaults to `nil`

    The mapper expects an `Cldr.Currency.t`

    # Examples

       => Cldr.Html.currency_select(:my_form, :currency, selected: :USD)
       => Cldr.Html.currency_select(:my_form, :currency, "USD", currencies: ["USD", "EUR", :JPY], mapper: &({&1.name, &1.code}))

    """
    @spec currency_select(Phoenix.HTML.Form.t(), Phoenix.HTML.Form.field(), currency_select_options) :: Phoenix.HTML.safe() | {:error, {Cldr.UnknownCurrencyError, binary()}} | {:error, {Cldr.UnknownLocaleError, binary()}}
    def currency_select(form, field, options \\ [selected: nil])
    def currency_select(form, field, options) do
      case validate_options(options) do
        {:error, reason} -> {:error, reason}

        validated        -> do_currency_select(form, field, validated)
      end
    end

    defp do_currency_select(form, field, options) do
      case options[:selected] do
        nil      -> Phoenix.HTML.Form.select(form, field, currency_options(options))

        selected -> Phoenix.HTML.Form.select(form, field, currency_options(options), [selected: selected])
      end
    end

    defp validate_options(options) do
      options
      |> default_options()
      |> validate_selected()
      |> validate_currencies()
      |> validate_locale()
    end

    defp default_options(options) do
      options
      |> Keyword.put_new(:currencies, Cldr.known_currencies())
      |> Keyword.put_new(:locale, Cldr.default_locale())
      |> Keyword.put_new(:mapper, &({&1.code <> " - " <> &1.name, &1.code}))
    end

    def validate_selected(options) do
      case options[:selected] do
        nil        -> options

        selected   ->
          case validate_currency(selected) do
            {:error, reason} -> {:error, reason}

            {:ok, _currency} -> options
          end
      end
    end

    defp validate_currencies({:error, reason}), do: {:error, reason}
    defp validate_currencies(options) do
      valiadeted_currencies = Enum.map(options[:currencies], &validate_currency/1)

      case Enum.find(valiadeted_currencies, &unknown_currency?/1) do
        {:error, reason} -> {:error, reason}

        _                -> options
      end
    end

    defp validate_currency(currency) do
      Cldr.validate_currency(currency)
    end

    defp validate_locale({:error, reason}), do: {:error, reason}
    defp validate_locale(options) do
      case Cldr.validate_locale(options[:locale]) do
        {:error, reason} -> {:error, reason}

        {:ok, _}         -> options
      end
    end

    defp unknown_currency?({:error, {Cldr.UnknownCurrencyError, _reason}}), do: true
    defp unknown_currency?({:ok, _code}), do: false

    defp currency_options(options) do
      options[:currencies]
      |> Enum.map(&Cldr.Currency.currency_for_code(&1, options[:locale]))
      |> Enum.map(fn {:ok, currency} -> options[:mapper].(currency) end)
      |> Enum.sort()
    end
  end

end
