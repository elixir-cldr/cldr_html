if Cldr.Code.ensure_compiled?(Cldr.Unit) do
  defmodule Cldr.HTML.Unit do
    @moduledoc """
    Implements `Phoenix.HTML.Form.select/4` specifically for
    localised unit display.

    """

    @type select_options :: [
            {:units, [atom() | binary(), ...]}
            | {:locale, Cldr.Locale.locale_name() | Cldr.LanguageTag.t()}
            | {:mapper, function()}
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

    * `:locale` defines the locale to be used to localise the
      description of the units.  The default is the locale
      returned by `Cldr.get_locale/0`

    * `:backend` is any backend module. The default is
      `Cldr.default_backend!/0`

    * `:mapper` is a function that creates the text to be
      displayed in the select tag for each unit.  It is
      passed the unit name.  The default function
      is `&({Cldr.Unit.display_name(&1), &1})`

    * `:selected` identifies the unit that is to be selected
      by default in the `select` tag.  The default is `nil`. This
      is passed unmodified to `Phoenix.HTML.Form.select/4`

    * `:prompt` is a prompt displayed at the top of the select
       box. This is passed unmodified to `Phoenix.HTML.Form.select/4`

    # Examples

         => Cldr.HTML.Unit.select(:my_form, :unit, selected: :foot)
         => Cldr.HTML.Unit.select(:my_form, :unit,
             units: [:foot, :inch], mapper: &{Cldr.Unit.display_name(&1, &2), &1})

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

    # Invalid options
    defp select(_form, _field, {:error, reason}, _selected) do
      {:error, reason}
    end

    # Selected currency
    defp select(form, field, options, _selected) do
      select_options =
        options
        |> Map.take([:selected, :prompt])
        |> Map.to_list

      options =
        options
        |> maybe_include_selected_unit
        |> unit_options

      Phoenix.HTML.Form.select(form, field, options, select_options)
    end

    defp validate_options(options) do
      with options <- Map.merge(default_options(), Map.new(options)),
           {:ok, options} <- validate_selected(options),
           {:ok, options} <- validate_units(options),
           {:ok, options} <- validate_locale(options) do
        options
      end
    end

    defp default_options do
      Map.new(
        units: default_unit_list(),
        backend: Cldr.default_backend!(),
        locale: Cldr.get_locale(),
        mapper: &{Cldr.Unit.display_name(&1, &2), &1},
        selected: nil
      )
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

    defp validate_locale(%{locale: locale} = options) do
      with {:ok, locale} <- Cldr.validate_locale(locale) do
        {:ok, Map.put(options, :locale, locale)}
      end
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

    defp unit_options(options) do
      options = Map.to_list(options)

      options[:units]
      |> Enum.map(fn unit -> options[:mapper].(unit, options) end)
      |> Enum.sort()
    end

    defp default_unit_list() do
      Cldr.Unit.known_units()
    end

  end
end
