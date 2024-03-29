defmodule Cldr.HTML.Locale.Test do
  use ExUnit.Case
  doctest Cldr.HTML.Locale

  import Phoenix.HTML, only: [safe_to_string: 1]

  describe "locale_select/3" do
    test "with selected locale" do
      string =
        safe_to_string(
          Cldr.HTML.Locale.select(
            :my_form,
            :locale,
            selected: "en",
            locales: ~w(en ja ar zh-Hant zh-Hans)
          )
        )

      assert string ==
               ~s{<select id="my_form_locale" lang="en-001" name="my_form[locale]">} <>
                 ~s{<option value="ar">Arabic</option>} <>
                 ~s{<option value="zh-Hans">Chinese (Simplified)</option>} <>
                 ~s{<option value="zh-Hant">Chinese (Traditional)</option>} <>
                 ~s{<option selected value="en">English</option>} <>
                 ~s{<option value="ja">Japanese</option>} <>
                 ~s{</select>}
    end

    test "with identity localization" do
      string =
        safe_to_string(
          Cldr.HTML.Locale.select(
            :my_form,
            :locale,
            locale: :identity
          )
        )

      assert string ==
               ~s{<select id=\"my_form_locale\" name=\"my_form[locale]\">} <>
                 ~s{<option lang=\"en\" value=\"en\">English</option>} <>
                 ~s{<option lang=\"he\" value=\"he\">עברית</option>} <>
                 ~s{<option lang=\"ar\" value=\"ar\">العربية</option>} <>
                 ~s{<option lang=\"th\" value=\"th\">ไทย</option>} <>
                 ~s{<option lang=\"zh\" value=\"zh\">中文</option>} <>
                 ~s{<option lang=\"zh-Hans\" value=\"zh-Hans\">中文（简体）</option>} <>
                 ~s{<option lang=\"zh-Hant\" value=\"zh-Hant\">中文（繁體）</option>} <>
                 ~s{</select>}
    end

    test "with unknown identity locale ja" do
      assert Cldr.HTML.Locale.select(:my_form, :locale, locale: :identity, locales: ["ja"]) ==
               {:error, {Cldr.UnknownLocaleError, "The locale \"ja\" is not known."}}
    end
  end

  describe "locale_options/1" do
    test "with selected locale" do
      options =
        Cldr.HTML.Locale.locale_options(
          locales: [:en, :ja, :ar],
          selected: :en
        )

      assert options == [{"Arabic", "ar"}, {"English", "en"}, {"Japanese", "ja"}]
    end
  end
end
