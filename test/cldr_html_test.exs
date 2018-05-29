defmodule Cldr.HTML.Test do
  use ExUnit.Case
  doctest Cldr.HTML

  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "currency_select/3" do
    test "with selected currency" do
      assert safe_to_string(
        Cldr.HTML.currency_select(:my_form, :currency, selected: :USD, currencies: ~w(USD EUR JPY COP))
      ) ==  ~s(<select id="my_form_currency" name="my_form[currency]" selected="USD">) <>
            ~s(<option value="COP">COP - Colombian Peso</option>) <>
            ~s(<option value="EUR">EUR - Euro</option>) <>
            ~s(<option value="JPY">JPY - Japanese Yen</option>) <>
            ~s(<option value="USD">USD - US Dollar</option>) <> ~s(</select>)

    end

    test "without selected currency" do
      assert safe_to_string(
        Cldr.HTML.currency_select(:my_form, :currency, currencies: ~w(USD EUR JPY COP))
      ) ==  ~s(<select id="my_form_currency" name="my_form[currency]">) <>
            ~s(<option value="COP">COP - Colombian Peso</option>) <>
            ~s(<option value="EUR">EUR - Euro</option>) <>
            ~s(<option value="JPY">JPY - Japanese Yen</option>) <>
            ~s(<option value="USD">USD - US Dollar</option>) <> ~s(</select>)

    end

    test "when selected currency is not in currencies" do
      assert safe_to_string(
        Cldr.HTML.currency_select(:my_form, :currency, selected: :USD, currencies: ~w(EUR JPY))
        ) ==  ~s(<select id="my_form_currency" name="my_form[currency]" selected="USD">) <>
              ~s(<option value="EUR">EUR - Euro</option>) <>
              ~s(<option value="JPY">JPY - Japanese Yen</option>) <>
              ~s(<option value="USD">USD - US Dollar</option>) <> ~s(</select>)
    end

    test "with thai locale" do
      assert safe_to_string(
        Cldr.HTML.currency_select(:my_form, :currency, currencies: ~w(USD EUR JPY COP), locale: "th")
      ) ==  ~s(<select id="my_form_currency" name="my_form[currency]">) <>
            ~s(<option value="COP">COP - เปโซโคลอมเบีย</option>) <>
            ~s(<option value="EUR">EUR - ยูโร</option>) <>
            ~s(<option value="JPY">JPY - เยนญี่ปุ่น</option>) <>
            ~s(<option value="USD">USD - ดอลลาร์สหรัฐ</option>) <> ~s(</select>)

    end

    test "with invalid selected" do
      assert Cldr.HTML.currency_select(:my_form, :currency, selected: ~w(invalid1), currencies: ~w(USD EUR JPY COP))
        == {:error, {Cldr.UnknownCurrencyError, "The currency [\"invalid1\"] is invalid"}}

    end

    test "with invalid currencies" do
      assert Cldr.HTML.currency_select(:my_form, :currency, currencies: ~w(invalid1 invalid2))
        == {:error, {Cldr.UnknownCurrencyError, "The currency \"invalid1\" is invalid"}}
    end

    test "with invalid locale" do
      assert Cldr.HTML.currency_select(:my_form, :currency, locale: "invalid")
        == {:error, {Cldr.UnknownLocaleError, "The locale \"invalid\" is not known."}}
    end
  end
end
