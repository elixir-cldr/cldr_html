# Changelog

## Cldr_HTML v1.5.0

This is the changelog for Cldr HTML v1.5.1 released on August 10th, 2023.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Fixes compile time module checking on Elixir 1.15 and OTP 25 or later. Thanks to @cw789 for the report. Closes #17.

## Cldr_HTML v1.5.0

This is the changelog for Cldr HTML v1.5.0 released on April 28th, 2023.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Fix omitting `:und` locale from the locale selection list

### Enhancements

* Updates to [ex_cldr version 2.37.0](https://hex.pm/packages/ex_cldr/2.37.0) which includes data from [CLDR release 43](https://cldr.unicode.org/index/downloads/cldr-43)

## Cldr_HTML v1.4.2

This is the changelog for Cldr HTML v1.4.2 released on October 17th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Fix type spec for select options to remove dialyzer warning. Thanks to @quentin-bettoum. Closes #16.

## Cldr_HTML v1.4.1

This is the changelog for Cldr HTML v1.4.1 released on September 10th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Adds `lang` attributes to locale selection to signal better information for accessibility. Thanks very much to @quentin-bettoum for the pull request. Closes #15.

## Cldr_HTML v1.4.0

This is the changelog for Cldr HTML v1.4.0 released on March 29th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* Adds `Cldr.HTML.Currency.currency_options/1`, `Cldr.HTML.Unit.unit_options/1` and `Cldr.HTML.Locale.locale_options/1` to generate a list of currency, unit and locale options that can be used in any case where a list of select options is required. Thanks to jokawachi-hg for the PR.

## Cldr_HTML v1.3.0

This is the changelog for Cldr HTML v1.3.0 released on March 25th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* Adds `Cldr.HTML.Territory.territory_options/1` to generate a list of territory options that can be used in any case where a list of territories is required (Not just in `Cldr.HTML.Territory.select/3`). Thanks to @fcarlislehg for the PR.

## Cldr_HTML v1.2.0

This is the changelog for Cldr HTML v1.2.0 released on March 2nd, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* Updates to [ex_cldr version 2.26.0](https://hex.pm/packages/ex_cldr/2.26.0) which uses atoms for locale names and rbnf locale names. This is consistent with out elements of `t:Cldr.LanguageTag` where atoms are used where the cardinality of the data is fixed and relatively small and strings where the data is free format.

## Cldr_HTML v1.1.0

This is the changelog for Cldr HTML v1.1.0 released on September 25th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Support `phoenix_html` version 3.0 in addition to earlier releases.

## Cldr_HTML v1.0.1

This is the changelog for Cldr HTML v1.0.1 released on September 2nd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Use `Cldr.Territory.country_codes/0` as the default territory list. Previously `Cldr.known_territories/0` was used. However that function returns a list of valid codes, not "known to CLDR" codes (which also needs fixing). Thanks to @walu-lila for the report. Fixes #10.

## Cldr_HTML v1.0.0

This is the changelog for Cldr HTML v1.0.0 released on July 3rd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* Add `Cldr.HTML.Locale.select/3` to select locales.

## Cldr_HTML v0.5.0

This is the changelog for Cldr HTML v0.5.0 released on June 23rd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Correctly sort the selection list. Thanks to @0urobor0s for the collaboration

* Pass options through to `Phoenix.HTML.Form.select/4`.  Thanks to @0urobor0s for the PR.

### Enhancements

* Adds a `:collator` option to the `Cldr.HTML.{Unit, Territory, Currency}.select/4`. This enables a library user to implement any desired collation on the select options before rendering.

## Cldr_HTML v0.4.0

This is the changelog for Cldr HTML v0.4.0 released on June 11th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Bug Fixes

* Make `ex_doc` only available in `:dev` and `:release`

## Cldr_HTML v0.3.0

This is the changelog for Cldr HTML v0.3.0 released on May 23rd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* Add `Cldr.HTML.Territory.select/3` to select territories

* Add support for `:style` option in `Cldr.HTML.Unit.select/3`

## Cldr_HTML v0.2.0

This is the changelog for Cldr HTML v0.2.0 released on February 7th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* Add `Cldr.HTML.Unit.unit_select/3`

* Use `Cldr.get_locale/0` not `Cldr.default_locale/0` as default parameter

## Cldr_HTML v0.1.0

This is the changelog for Cldr HTML v0.1.0 released on November 1st, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr_html/tags)

### Enhancements

* First hex release

* Support [CLDR 38](http://cldr.unicode.org/index/downloads/cldr-38)
