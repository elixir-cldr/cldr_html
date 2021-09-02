# Changelog

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

* Adds a `:collator` option to the `Cldr.HTML.{Unit, Territory, Currency}.select/4`. This enables a library user to implement any desired collation on the select opions before rendering.

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
