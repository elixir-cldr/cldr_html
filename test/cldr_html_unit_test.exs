defmodule Cldr.HTML.Unit.Test do
  use ExUnit.Case
  doctest Cldr.HTML.Unit

  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "unit_select/3" do
    test "with selected unit" do
      string =
        safe_to_string(
          Cldr.HTML.Unit.select(
            :my_form,
            :unit,
            units: [:foot, :inch],
            selected: :foot,
            units: [:foot, :inch]
          )
        )

      assert string ==
               ~s(<select id="my_form_unit" name="my_form[unit]">) <>
                 ~s(<option selected value="foot">feet</option>) <>
                 ~s(<option value="inch">inches</option>) <>
                 ~s(</select>)
    end

    test "with selected unit and style" do
      string =
        safe_to_string(
          Cldr.HTML.Unit.select(
            :my_form,
            :unit,
            units: [:foot, :inch],
            selected: :foot,
            style: :narrow,
            units: [:foot, :inch]
          )
        )

      assert string ==
               ~s(<select id="my_form_unit" name="my_form[unit]">) <>
                 ~s(<option selected value="foot">ft</option>) <>
                 ~s(<option value="inch">in</option>) <>
                 ~s(</select>)
    end

    test "with locale" do
      string =
        safe_to_string(
          Cldr.HTML.Unit.select(
            :my_form,
            :unit,
            units: [:foot, :inch],
            selected: :foot,
            locale: "th"
          )
        )

      assert string ==
               ~s(<select id="my_form_unit" name="my_form[unit]">) <>
                 ~s(<option selected value="foot">ฟุต</option>) <>
                 ~s(<option value="inch">นิ้ว</option>) <>
                 ~s(</select>)
    end
  end

  describe "unit_options/1" do
    test "with selected unit" do
      options =
        Cldr.HTML.Unit.unit_options(
          units: [:foot, :inch],
          selected: :foot
        )

      assert options == [{"feet", "foot"}, {"inches", "inch"}]
    end
  end
end
