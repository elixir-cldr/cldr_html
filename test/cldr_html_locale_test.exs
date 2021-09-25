defmodule Cldr.HTML.Locale.Test do
  use ExUnit.Case
  doctest Cldr.HTML.Locale

  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "locale_select/3" do
    test "with selected locale" do
      string = safe_to_string(
               Cldr.HTML.Locale.select(
                 :my_form,
                 :locale,
                 selected: "en",
                 locales: ~w(en ja ar zh-Hant zh-Hans)
               )
             )
      assert string ==
        ~s{<select id="my_form_locale" name="my_form[locale]">} <>
        ~s{<option value="ar">Arabic</option>} <>
        ~s{<option value="zh-Hans">Chinese (Simplified)</option>} <>
        ~s{<option value="zh-Hant">Chinese (Traditional)</option>} <>
        ~s{<option selected value="en">English</option>} <>
        ~s{<option value="ja">Japanese</option>} <>
        ~s{</select>}

    end

    test "with identity localization" do
      string = safe_to_string(
               Cldr.HTML.Locale.select(
                 :my_form,
                 :locale,
                 locale: :identity
               )
             )
      assert string ==
         ~s{<select id=\"my_form_locale\" name=\"my_form[locale]\">} <>
         ~s{<option value=\"en\">English</option>} <>
         ~s{<option value=\"he\">עברית</option>} <>
         ~s{<option value=\"ar\">العربية</option>} <>
         ~s{<option value=\"th\">ไทย</option>} <>
         ~s{<option value=\"zh-Hans\">中文（简体）</option>} <>
         ~s{<option value=\"zh-Hant\">中文（繁體）</option>} <>
         ~s{</select>}

    end

    test "with unknown identity locale ja" do
      assert Cldr.HTML.Locale.select(:my_form, :locale, locale: :identity, locales: ["ja"]) ==
        {:error, {Cldr.UnknownLocaleError, "The locale \"ja\" is not known."}}
    end

  end
end