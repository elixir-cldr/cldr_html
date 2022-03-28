if Cldr.Code.ensure_compiled?(Cldr.Unit) do
  defmodule Cldr.HTML.Unit do
    @moduledoc """
    Implements `Phoenix.HTML.Form.select/4` specifically for
    localised unit display.

    """

    @type select_options :: [
            {:units, [atom() | binary(), ...]}
            | {:locale, Cldr.Locale.locale_name() | Cldr.LanguageTag.t()}
            | {:collator, function()}
            | {:mapper, (Cldr.Unit.t() -> String.t())}
            | {:backend, module()}
            | {:selected, atom() | binary()}
          ]

    @doc """
    Generate an HTML select tag for a unit list
    that can be used with a `Phoenix.HTML.Form.t`.

    ## Arguments

    * A `t:Phoenix.HTML.Form` form

    * A `t:Phoenix.HTML.Form.field` field

    * A `t:Keyword` list of options

    ## Options

    For select options see `Phoenix.HTML.Form.select/4`

    * `:units` is a list of units to be displayed in the
      select. See `Cldr.Unit.known_units/0` and
      `Cldr.Unit.known_units_for_category/1`

    * `:style` is the style of unit name to be displayed and
      must be one of the styles returned by `Cldr.Unit.known_styles/0`.
      The current styles are :long, :short and :narrow.
      The default is style: :long.

    * `:locale` defines the locale to be used to localise the
      description of the units.  The default is the locale
      returned by `Cldr.get_locale/0`

    * `:backend` is any backend module. The default is
      `Cldr.default_backend!/0`

    * `:collator` is a function used to sort the units
      in the selection list. It is passed a list of tuples where
      each tuple is in the form `{unit_display_name, unit}`.
      The default collator sorts by `name_1 < name_2`.
      As a result, default collation sorts by code point which
      will not return expected results for scripts other than Latin.

    * `:mapper` is a function that creates the text to be
      displayed in the select tag for each unit.  It is
      passed the a tuple of the form `{unit_display_name, unit}`,
      The default is the identity function `&(&1)`.

    * `:selected` identifies the unit that is to be selected
      by default in the `select` tag.  The default is `nil`. This
      is passed unmodified to `Phoenix.HTML.Form.select/4`

    * `:prompt` is a prompt displayed at the top of the select
       box. This is passed unmodified to `Phoenix.HTML.Form.select/4`

    # Examples

         => Cldr.HTML.Unit.select(:my_form, :unit, selected: :foot)
         => Cldr.HTML.Unit.select(:my_form, :unit, units: [:foot, :inch])

    """
    @spec select(
            form :: Phoenix.HTML.Form.t(),
            field :: Phoenix.HTML.Form.field(),
            select_options
          ) ::
            Phoenix.HTML.safe()
            | {:error, {Cldr.UnknownUnitError, binary()}}
            | {:error, {Cldr.UnknownLocaleError, binary()}}

    def select(form, field, options \\ [])

    def select(form, field, options) when is_list(options) do
      select(form, field, validate_options(options), options[:selected])
    end

    @doc """
    Generate a list of options for a unit list
    that can be used with `Phoenix.HTML.Form.select/4`,
    `Phoenix.HTML.Form.options_for_select/2` or
    to create a <datalist>.

    ## Arguments

    * A `Keyword.t()` list of options,

    ## Options

    See `Cldr.HTML.Unit.select/3` for options.

    """
    @spec unit_options(select_options) ::
            list(tuple())
            | {:error, {Cldr.UnknownUnitError, binary()}}
            | {:error, {Cldr.UnknownLocaleError, binary()}}

    def unit_options(options \\ [])

    def unit_options(options) when is_list(options) do
      options
      |> validate_options()
      |> build_unit_options()
    end

    # Invalid options
    defp select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # Selected currency
    @omit_from_select_options [:units, :locale, :mapper, :collator, :backend, :style]
    defp select(form, field, options, _selected) do
      select_options =
        options
        |> Map.drop(@omit_from_select_options)
        |> Map.to_list()

      options = build_unit_options(options)

      Phoenix.HTML.Form.select(form, field, options, select_options)
    end

    defp validate_options(options) do
      with options <- Map.merge(default_options(), Map.new(options)),
           {:ok, options} <- validate_locale(options),
           {:ok, options} <- validate_selected(options),
           {:ok, options} <- validate_units(options),
           {:ok, options} <- validate_style(options) do
        options
      end
    end

    defp default_options do
      Map.new(
        units: default_unit_list(),
        backend: nil,
        locale: Cldr.get_locale(),
        collator: &default_collator/1,
        mapper: & &1,
        style: :long,
        selected: nil
      )
    end

    defp default_collator(units) do
      Enum.sort(units, &default_comparator/2)
    end

    # Note that this is not a unicode aware comparison
    # It sorts by the display name
    defp default_comparator({_, unit_1}, {_, unit_2}) do
      unit_1 < unit_2
    end

    defp validate_selected(%{selected: nil} = options) do
      {:ok, options}
    end

    defp validate_selected(%{selected: selected} = options) do
      with {:ok, unit, _conversion} <- Cldr.Unit.validate_unit(selected) do
        {:ok, Map.put(options, :selected, unit)}
      end
    end

    # Return a list of validated units or an error
    defp validate_units(%{units: units} = options) do
      validate_units(units, options)
    end

    defp validate_units(units) when is_list(units) do
      Enum.reduce_while(units, [], fn unit, acc ->
        case Cldr.Unit.validate_unit(unit) do
          {:ok, unit, _conversion} -> {:cont, [unit | acc]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end

    defp validate_units(units, options) do
      case validate_units(units) do
        {:error, reason} -> {:error, reason}
        units -> {:ok, Map.put(options, :units, Enum.reverse(units))}
      end
    end

    defp validate_style(options) do
      with {:ok, style} <- Cldr.Unit.validate_style(options[:style]) do
        {:ok, Map.put(options, :style, style)}
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

    defp maybe_include_selected_unit(%{selected: nil} = options) do
      options
    end

    defp maybe_include_selected_unit(%{units: units, selected: selected} = options) do
      if Enum.any?(units, &(&1 == selected)) do
        options
      else
        Map.put(options, :units, [selected | units])
      end
    end

    defp build_unit_options(options) when is_map(options) do
      options = maybe_include_selected_unit(options)

      units = Map.fetch!(options, :units)
      collator = Map.fetch!(options, :collator)
      mapper = Map.fetch!(options, :mapper)
      options = Map.to_list(options)

      units
      |> Enum.map(&to_selection_tuple(&1, options))
      |> collator.()
      |> Enum.map(&mapper.(&1))
    end

    defp to_selection_tuple(unit, options) do
      display_name = Cldr.Unit.display_name(unit, options)
      unit_code = to_string(unit)
      {display_name, unit_code}
    end

    defp default_unit_list() do
      Cldr.Unit.known_units()
    end
  end
end
