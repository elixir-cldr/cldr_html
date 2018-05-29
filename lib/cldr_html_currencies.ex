if Code.ensure_compiled?(Cldr.Currency) do
  defmodule Cldr.HTML.Currency do
    @type select_options :: [
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
    def select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # No selected currency
    def select(form, field, options, nil) do
      Phoenix.HTML.Form.select(form, field, currency_options(options))
    end

    # Selected currency
    def select(form, field, options, selected) do
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
        currencies: Cldr.known_currencies(),
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
      with {:ok, _locale} <- Cldr.validate_locale(locale) do
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
  end
end
