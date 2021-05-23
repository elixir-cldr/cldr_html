defmodule Cldr.HTML.Unit.Test do
  use ExUnit.Case
  doctest Cldr.HTML.Unit

  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "unit_select/3" do
    test "with selected unit" do
      string = safe_to_string(
               Cldr.HTML.Unit.select(
                 :my_form,
                 :unit,
                 units: [:foot, :inch],
                 selected: :foot,
                 currencies: ~w(:foot :inch)
               )
             )
      assert string ==
         ~s(<select id="my_form_unit" name="my_form[unit]">) <>
         ~s(<option value="foot" selected>feet</option>) <>
         ~s(<option value="inch">inches</option>) <>
         ~s(</select>)

    end

    test "with selected unit and style" do
      string = safe_to_string(
               Cldr.HTML.Unit.select(
                 :my_form,
                 :unit,
                 units: [:foot, :inch],
                 selected: :foot,
                 style: :narrow,
                 currencies: ~w(:foot :inch)
               )
             )
      assert string ==
         ~s(<select id="my_form_unit" name="my_form[unit]">) <>
         ~s(<option value="foot" selected>ft</option>) <>
         ~s(<option value="inch">in</option>) <>
         ~s(</select>)

    end

    test "with locale" do
      string = safe_to_string(
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
         ~s(<option value="inch">นิ้ว</option>) <>
         ~s(<option value="foot" selected>ฟุต</option>) <>
         ~s(</select>)
    end
  end
end