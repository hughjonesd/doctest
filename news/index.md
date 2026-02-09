# Changelog

## doctest (development version)

- Do not produce `Source line` to avoid changes irrelevant to examples
  modifying the tests.

## doctest 0.3.0

CRAN release: 2024-01-11

- Added a `@doctestExample` tag as a drop-in replacement for `@example`.
- Error handling has been improved.
- Fix compatibility with roxygen 7.3.0. Thanks
  [@hadley](https://github.com/hadley).

## doctest 0.2.0

CRAN release: 2023-04-28

- First CRAN release.
- Added a `NEWS.md` file to track changes to the package.
- Fixed compatibility with purrr 1.0.0.
- New vignette “Converting a package to use doctest”.
