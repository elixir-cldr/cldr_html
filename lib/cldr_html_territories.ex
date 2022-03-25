if Cldr.Code.ensure_compiled?(Cldr.Territory) do
  defmodule Cldr.HTML.Territory do
    @moduledoc """
    Implements `Phoenix.HTML.Form.select/4` specifically for
    localised territory display.

    """

    @type select_options :: [
            {:territories, [atom() | binary(), ...]}
            | {:locale, Cldr.Locale.locale_name() | Cldr.LanguageTag.t()}
            | {:collator, function()}
            | {:mapper, (Cldr.Locale.territory_code() -> String.t())}
            | {:backend, module()}
            | {:selected, atom() | binary()}
          ]

    @typedoc """
    Territory type passed to a collator for ordering in the select box.

    The default collator orders by `:name` using Elixir standard
    comparison which is by codepoint and is therefore not Unicode
    aware.

    """
    @type territory :: %{
            territory: Cldr.Locale.territory_code(),
            name: String.t(),
            flag: String.t()
          }

    @doc """
    Generate an HTML select tag for a territory list
    that can be used with a `Phoenix.HTML.Form.t`.

    ## Arguments

    * A `Phoenix.HTML.Form.t()` form

    * A `Phoenix.HTML.Form.field()` field

    * A `Keyword.t()` list of options

    ## Options

    For select options see `Phoenix.HTML.Form.select/4`

    * `:territories` defines the list of territories to be
      displayed in the the `select` tag.  The list defaults to
      the territories returned by `Cldr.Territory.country_codes/0`.

    * `:style` is the format of the territory name to be used.
      The options are `:standard` (the default), `:short` and `:variant`.
      Not all territories have `:short` or `:variant` names in which
      case `:standard` is used for those territories.

    * `:locale` defines the locale to be used to localise the
      description of the territories.  The default is the locale
      returned by `Cldr.get_locale/1`

    * `:backend` is any backend module. The default is
      `Cldr.default_backend!/0`

    * `:collator` is a function used to sort the territories
      in the selection list. It is passed a list of maps where
      each map represents a territory and has the keys `:territory`,
      `:name` and `:flag`. See `t:territory`. The default collator
      sorts by `name_1 < name_2`. As a result, default collation
      sorts by code point which will not return expected results
      for scripts other than Latin.

    * `:mapper` is a function that creates the text to be
      displayed in the select tag for each territory.  It is
      passed the territory definition as a `t:territory` map
      containing the keys `:territory_code`, `:name` and
      `:flag`.  The default function is
      `&({&1.flag <> " " <> &1.name, &1.territory_code})`

    * `:selected` identifies the territory that is to be selected
      by default in the `select` tag.  The default is `nil`. This
      is passed unmodified to `Phoenix.HTML.Form.select/4`

    * `:prompt` is a prompt displayed at the top of the select
       box. This is passed unmodified to `Phoenix.HTML.Form.select/4`

    # Examples

         Cldr.HTML.Territory.select(:my_form, :territory, selected: :AU)

         Cldr.HTML.Territory.select(:my_form, :territory, selected: :AU, locale: "ar")

         Cldr.HTML.Territory.select(:my_form, :territory, territories: [:US, :AU, :JP],
              mapper: &({&1.name, &1.territory_code}))

    """
    @spec select(
            form :: Phoenix.HTML.Form.t(),
            field :: Phoenix.HTML.Form.field(),
            select_options
          ) ::
            Phoenix.HTML.safe()
            | {:error, {Cldr.UnknownTerritoryError, binary()}}
            | {:error, {Cldr.UnknownLocaleError, binary()}}

    def select(form, field, options \\ [])

    def select(form, field, options) when is_list(options) do
      select(form, field, validate_options(options), options[:selected])
    end

    @doc """
    Generate a list of options for a territory list
    that can be used with `Phoenix.HTML.Form.select/4`,
    `Phoenix.HTML.Form.options_for_select/2` or
    to create a <datalist>.

    ## Arguments

    * A `Keyword.t()` list of options

    ## Options

    See `Cldr.HTML.Territory.select/3` for options.
    """
    @spec territory_options(select_options) ::
            list(tuple())
            | {:error, {Cldr.UnknownTerritoryError, binary()}}
            | {:error, {Cldr.UnknownLocaleError, binary()}}

    def territory_options(options \\ [])

    def territory_options(options) when is_list(options) do
      options
      |> validate_options()
      |> build_territory_options()
    end

    # Invalid options
    defp select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # Selected territory
    @omit_from_select_options [:territories, :locale, :mapper, :collator, :backend, :style]
    defp select(form, field, options, _selected) do
      select_options =
        options
        |> Map.drop(@omit_from_select_options)
        |> Map.to_list()

      options = build_territory_options(options)

      Phoenix.HTML.Form.select(form, field, options, select_options)
    end

    defp validate_options(options) do
      options = Map.new(options)

      with options <- Map.merge(default_options(), options),
           {:ok, options} <- validate_locale(options),
           {:ok, options} <- validate_selected(options),
           {:ok, options} <- validate_territories(options) do
        options
      end
    end

    defp default_options do
      Map.new(
        territories: default_territory_list(),
        locale: Cldr.get_locale(),
        backend: nil,
        collator: &default_collator/1,
        mapper: &{&1.flag <> " " <> &1.name, &1.territory_code},
        selected: nil
      )
    end

    defp validate_selected(%{selected: nil} = options) do
      {:ok, options}
    end

    defp validate_selected(%{selected: selected} = options) do
      with {:ok, territory} <- Cldr.validate_territory(selected) do
        {:ok, Map.put(options, :selected, territory)}
      end
    end

    # Return a list of validated territories or an error
    defp validate_territories(%{territories: territories} = options) do
      validate_territories(territories, options)
    end

    defp validate_territories(territories) when is_list(territories) do
      Enum.reduce_while(territories, [], fn territory, acc ->
        case Cldr.validate_territory(territory) do
          {:ok, territory} -> {:cont, [territory | acc]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp validate_territories(territories, options) do
      case validate_territories(territories) do
        {:error, reason} -> {:error, reason}
        territories -> {:ok, Map.put(options, :territories, Enum.reverse(territories))}
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

    defp maybe_include_selected_territory(%{selected: nil} = options) do
      options
    end

    defp maybe_include_selected_territory(
           %{territories: territories, selected: selected} = options
         ) do
      if Enum.any?(territories, &(&1 == selected)) do
        options
      else
        Map.put(options, :territories, [selected | territories])
      end
    end

    defp build_territory_options(options) when is_map(options) do
      options = maybe_include_selected_territory(options)

      territories = Map.fetch!(options, :territories)
      collator = Map.fetch!(options, :collator)
      mapper = Map.fetch!(options, :mapper)

      territories
      |> Enum.map(&territory_info(&1, options))
      |> collator.()
      |> Enum.map(&mapper.(&1))
    end

    defp default_collator(territories) do
      Enum.sort(territories, &default_comparator/2)
    end

    # Note that this is not a unicode aware comparison
    defp default_comparator(territory_1, territory_2) do
      territory_1.name < territory_2.name
    end

    defp territory_info(territory, %{backend: backend} = options) do
      options = info_options(options)
      name = name_from_territory(territory, backend, options)
      flag = flag_from_territory(territory)

      %{territory_code: territory, name: name, flag: flag}
    end

    defp name_from_territory(territory, backend, options) do
      with {:ok, name} <- Cldr.Territory.from_territory_code(territory, backend, options) do
        name
      else
        {:error, {Cldr.UnknownStyleError, _}} ->
          default_style_options = Keyword.delete(options, :style)
          Cldr.Territory.from_territory_code!(territory, backend, default_style_options)
      end
    end

    defp flag_from_territory(territory) do
      with {:ok, flag} <- Cldr.Territory.to_unicode_flag(territory) do
        flag
      else
        _ -> " "
      end
    end

    defp info_options(%{locale: locale, style: style}) do
      [locale: locale, style: style]
    end

    defp info_options(%{locale: locale}) do
      [locale: locale]
    end

    defp info_options(%{style: style}) do
      [style: style]
    end

    defp default_territory_list() do
      Cldr.Territory.country_codes()
    end
  end
end
