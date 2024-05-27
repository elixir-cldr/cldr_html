if match?({:module, _}, Code.ensure_compiled(Cldr.LocaleDisplay)) do
  defmodule Cldr.HTML.Locale do
    @moduledoc """
    Implements `Phoenix.HTML.Form.select/4` specifically for
    localised locale display.

    """

    alias Cldr.Locale

    @type select_options :: [
            {:locales, [atom() | binary(), ...]}
            | {:locale, Cldr.Locale.locale_name() | Cldr.LanguageTag.t()}
            | {:collator, function()}
            | {:mapper, function()}
            | {:backend, module()}
            | {:selected, atom() | binary()}
            | {atom(), any()}
          ]

    @type locale :: %{
            locale: String.t(),
            display_name: String.t(),
            language_tag: Cldr.LanguageTag.t()
          }

    @type mapper :: (locale() -> String.t())

    @identity :identity

    # All configurations include these locales
    # but they shouldn't be presented for
    # display
    @dont_include_default [:"en-001", :root, :und]

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
      `Cldr.known_locale_names/0`. If `:backend` is specified
      then the list of locales known to that backend
      is returned. If no `:backend` is specified the
      locales known to `Cldr.default_backend!/0` is
      returned.

    * `:locale` defines the locale to be used to localise the
      description of the list of locales.  The default is the locale
      returned by `Cldr.get_locale/1` If set to `:identity` then
      each locale in the `:locales` list will be rendered in its
      own locale.

    * `:backend` is any backend module. The default is
      `Cldr.default_backend!/0`

    * `:collator` is a function used to sort the locales
      in the selection list. It is passed a list of maps where
      each map represents a locale. The default collator
      sorts by `locale_1.display_name < locale_2.display_name`.
      As a result, default collation sorts by code point
      which will not return expected results
      for scripts other than Latin.

    * `:mapper` is a function that creates the text to be
      displayed in the select tag for each locale.  It is
      passed a map with three fields: `:display_name`, `:locale`
      and `:language_tag`. The default mapper is
      `&{&1.display_name, &1.locale}`. See `t:locale`.

    * `:selected` identifies the locale that is to be selected
      by default in the `select` tag.  The default is `nil`. This
      is passed to `Phoenix.HTML.Form.select/4`

    * `:prompt` is a prompt displayed at the top of the select
       box. This is passed unmodified to `Phoenix.HTML.Form.select/4`

    ## Notes

    If `:locale` is set to `:identity` then each locale in
    `:locales` will be used to render its own display name. In
    this case each locale in `:locales` must also be configured
    in the `:backend` or an error will be returned.

    ## Examples

         Cldr.HTML.Currency.select(:my_form, :locale_list, selected: "en")

         Cldr.HTML.Currency.select(:my_form, :locale_list,
           locales: ["zh-Hant", "ar", "fr"],
           mapper: &({&1.display_name, &1.locale}))

    """
    @spec select(
            form :: Phoenix.HTML.Form.t(),
            field :: Phoenix.HTML.Form.field(),
            select_options
          ) ::
            Phoenix.HTML.safe() | {:error, {Cldr.UnknownLocaleError, binary()}}

    def select(form, field, options \\ [])

    def select(form, field, options) when is_list(options) do
      select(form, field, validate_options(options), options[:selected])
    end

    @doc """
    Generate a list of options for a locale list
    that can be used with `Phoenix.HTML.Form.select/4`,
    `Phoenix.HTML.Form.options_for_select/2` or
    to create a <datalist>.

    ## Arguments

    * A `Keyword.t()` list of options.

    ## Options

    See `Cldr.HTML.Locale.select/3` for options.

    """
    @spec locale_options(select_options) ::
            list(tuple()) | {:error, {Cldr.UnknownLocaleError, binary()}}

    def locale_options(options \\ [])

    def locale_options(options) when is_list(options) do
      options
      |> validate_options()
      |> build_locale_options()
    end

    # Invalid options
    defp select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # Selected currency
    @omit_from_select_options [
      :locales,
      :locale,
      :mapper,
      :collator,
      :backend,
      :add_likely_subtags,
      :prefer,
      :compound_locale
    ]

    if function_exported?(Phoenix.HTML.Form, :select, 4) do
      defp select(form, field, %{locale: locale} = options, _selected) do
        select_options =
          options
          |> Map.drop(@omit_from_select_options)
          |> Map.to_list()

        options = build_locale_options(options)
        {options, select_options} = add_lang_attribute(locale, options, select_options)

        Phoenix.HTML.Form.select(form, field, options, select_options)
      end
    else
      defp select(form, field, %{locale: locale} = options, _selected) do
        select_options =
          options
          |> Map.drop(@omit_from_select_options)
          |> Map.to_list()

        options = build_locale_options(options)
        {options, select_options} = add_lang_attribute(locale, options, select_options)

        selected = Keyword.get(select_options, :selected)
        safe_options =
          options
          |> Phoenix.HTML.Form.options_for_select(selected)
          |> Phoenix.HTML.safe_to_string()

        lang = Keyword.take(select_options, [:lang])
        safe_attrs =
          [
            id: Phoenix.HTML.Form.input_id(form, field),
            name: Phoenix.HTML.Form.input_name(form, field)
          ]
          |> Kernel.++(lang)
          |> Enum.sort()
          |> Phoenix.HTML.attributes_escape()
          |> Phoenix.HTML.safe_to_string()

        ["<select", safe_attrs, ?>, safe_options, "</select>"]
        |> IO.iodata_to_binary()
        |> Phoenix.HTML.raw()
      end
    end

    # For the :identity case, add a :lang attribute to each select option
    defp add_lang_attribute(@identity, options, select_options) do
      options = Enum.map(options, fn {key, value} -> [key: key, value: value, lang: value] end)
      {options, select_options}
    end

    # For the non-identity case, add one :lang attribute to the whole select
    defp add_lang_attribute(locale, options, select_options) do
      {options, Keyword.put(select_options, :lang, locale)}
    end

    defp validate_options(options) do
      options = Map.new(options)

      with options <- Map.merge(default_options(), options),
           {:ok, options} <- validate_locale(options.locale, options),
           {:ok, options} <- validate_selected(options.selected, options),
           {:ok, options} <- validate_locales(options.locales, options),
           {:ok, options} <- validate_identity_locales(options.locale, options) do
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
        compound_locale: false,
        prefer: :default
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
      list_options =
        options
        |> Map.take([:add_likely_subtags])
        |> Map.to_list()

      backend = options[:backend]

      with {:ok, locale} <- Locale.canonical_language_tag(selected, backend, list_options) do
        {:ok, Map.put(options, :selected, locale)}
      end
    end

    # Return a list of validated locales or an error
    defp validate_locales(nil, options) do
      default_locales = Cldr.known_locale_names(options[:backend]) -- @dont_include_default
      validate_locales(default_locales, options)
    end

    defp validate_locales(locales, options) when is_list(locales) do
      list_options =
        options
        |> Map.take([:add_likely_subtags])
        |> Map.to_list()

      backend = options[:backend]

      Enum.reduce_while(locales, [], fn locale, acc ->
        case Locale.canonical_language_tag(to_string(locale), backend, list_options) do
          {:ok, locale} -> {:cont, [locale | acc]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
      |> case do
        {:error, reason} -> {:error, reason}
        locales -> {:ok, Map.put(options, :locales, locales)}
      end
    end

    defp validate_identity_locales(@identity, options) do
      Enum.reduce_while(options.locales, {:ok, options}, fn locale, acc ->
        case Cldr.validate_locale(locale, options.backend) do
          {:ok, _locale} -> {:cont, acc}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp validate_identity_locales(_locale, options) do
      options
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
      if Enum.any?(locales, &(&1.canonical_locale_name == selected.canonical_locale_name)) do
        options
      else
        Map.put(options, :locales, [selected | locales])
      end
    end

    defp build_locale_options(options) when is_map(options) do
      options = maybe_include_selected_locale(options)

      locales = Map.fetch!(options, :locales)
      locale = Map.fetch!(options, :locale)
      collator = Map.fetch!(options, :collator)
      mapper = Map.fetch!(options, :mapper)
      display_options = Map.take(options, [:prefer, :compound_locale]) |> Map.to_list()

      locales
      |> Enum.map(&display_name(&1, locale, display_options))
      |> collator.()
      |> Enum.map(&mapper.(&1))
    end

    defp display_name(locale, @identity, options) do
      if is_nil(locale.cldr_locale_name) do
        raise Cldr.UnknownLocaleError, "The locale #{locale.canonical_locale_name} is not known"
      end

      options = Keyword.put(options, :locale, locale)
      display_name = Cldr.LocaleDisplay.display_name!(locale, options)
      %{locale: locale.canonical_locale_name, display_name: display_name, language_tag: locale}
    end

    defp display_name(locale, _in_locale, options) do
      display_name = Cldr.LocaleDisplay.display_name!(locale, options)
      %{locale: locale.canonical_locale_name, display_name: display_name, language_tag: locale}
    end

    defimpl Phoenix.HTML.Safe, for: Cldr.LanguageTag do
      def to_iodata(language_tag) do
        language_tag.canonical_locale_name
      end
    end
  end
end
