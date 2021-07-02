defmodule Cldr.HTML.Locale do
  @moduledoc """
  Implements `Phoenix.HTML.Form.select/4` specifically for
  localised locale display.

  """

  @type select_options :: [
          {:locales, [atom() | binary(), ...]}
          | {:locale, Cldr.Locale.locale_name() | Cldr.LanguageTag.t()}
          | {:collator, function()}
          | {:mapper, function()}
          | {:backend, module()}
          | {:selected, atom() | binary()}
        ]

  @identity :identity

  @doc """
  Generate an HTML select tag for a locale list
  that can be used with a `Phoenix.HTML.Form.t`.

  ## Arguments

  * A `Phoenix.HTML.Form.t()` form

  * A `Phoenix.HTML.Form.field()` field

  * A `Keyword.t()` list of options

  ## Options

  For select options see `Phoenix.HTML.Form.select/4`

  * `:locales` defines the list of locales to be
    displayed in the the `select` tag.  The list defaults to
    `Cldr.known_locales/1`. If `:backend` is specified
    then the list of locales known to that backend
    is returned. If no `:backend` is specified the
    localed known to `Cldr.default_backend!/0` is
    returned.

  * `:locale` defines the locale to be used to localise the
    description of the currencies.  The default is the locale
    returned by `Cldr.get_locale/1` If set to `:identity` then
    each locale in the `:locales` list will be rendered in it
    own locale.

  * `:backend` is any backend module. The default is
    `Cldr.default_backend!/0`

  * `:collator` is a function used to sort the territories
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

  # Invalid options
  defp select(_form, _field, {:error, reason}, _selected) do
    {:error, reason}
  end

  # Selected currency
  @omit_from_select_options [
    :locales, :locale, :mapper, :collator, :backend,
    :add_likely_subtags, :prefer, :compound_locale
  ]

  defp select(form, field, options, _selected) do
    select_options =
      options
      |> Map.drop(@omit_from_select_options)
      |> Map.to_list

    options =
      options
      |> maybe_include_selected_locale()
      |> locale_options()

    Phoenix.HTML.Form.select(form, field, options, select_options)
  end

  defp validate_options(options) do
    options = Map.new(options)

    with options <- Map.merge(default_options(), options),
         {:ok, options} <- validate_locale(options.locale, options),
         {:ok, options} <- validate_selected(options.selected, options),
         {:ok, options} <- validate_locales(options.locales, options) do
      options
    end
  end

  defp default_options do
    Map.new(
      locales: nil,
      locale: Cldr.get_locale(),
      backend: nil,
      collator: &default_collator/1,
      mapper: &{&1.display_name, &1.locale},
      selected: nil,
      add_likely_subtags: false,
      compound_locale: false
    )
  end

  defp default_collator(locales) do
    Enum.sort(locales, &default_comparator/2)
  end

  # Note that this is not a unicode aware comparison
  defp default_comparator(locale_1, locale_2) do
    locale_1.display_name < locale_2.display_name
  end

  defp validate_selected(nil, options) do
    {:ok, options}
  end

  defp validate_selected(selected, options) do
    with {:ok, locale} <- Cldr.validate_locale(selected, options.backend) do
      {:ok, Map.put(options, :selected, locale)}
    end
  end

  # Return a list of validated currencies or an error
  defp validate_locales(nil, options) do
    validate_locales(Cldr.known_locale_names(options[:backend]), options)
  end

  defp validate_locales(locales, options) when is_list(locales) do
    list_options = Map.to_list(options)

    Enum.reduce_while(locales, [], fn locale, acc ->
      case Cldr.Locale.canonical_language_tag(locale, options[:backend], list_options) do
        {:ok, locale} -> {:cont, [locale | acc]}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:error, reason} -> {:error, reason}
      locales -> Map.put(options, :locales, locales)
    end
  end

  defp validate_locale(:identity, options) do
    {_locale, backend} = Cldr.locale_and_backend_from(nil, options[:backend])
    {:ok, Map.put(options, :backend, backend)}
  end

  defp validate_locale(locale, options) do
    {locale, backend} = Cldr.locale_and_backend_from(locale, options.backend)
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

  defp maybe_include_selected_locale(%{selected: nil} = options) do
    options
  end

  defp maybe_include_selected_locale(%{locales: locales, selected: selected} = options) do
    if Enum.any?(locales, &(&1 == selected)) do
      options
    else
      Map.put(options, :locales, [selected | locales])
    end
  end

  defp locale_options(options) do
    locales = Map.fetch!(options, :locales)
    collator = Map.fetch!(options, :collator)
    mapper = Map.fetch!(options, :mapper)
    options = Map.to_list(options)

    locales
    |> Enum.map(&display_name(&1, options[:locale], options))
    |> collator.()
    |> Enum.map(&mapper.(&1))
  end

  defp display_name(locale, @identity, options) do
    options = Keyword.put(options, :locale, locale)
    display_name = Cldr.LocaleDisplay.display_name!(locale, options)
    %{locale: locale.cldr_locale_name, display_name: display_name, language_tag: locale}
  end

  defp display_name(locale, _in_locale, options) do
    display_name = Cldr.LocaleDisplay.display_name!(locale, options)
    %{locale: locale.cldr_locale_name, display_name: display_name, language_tag: locale}
  end

end

