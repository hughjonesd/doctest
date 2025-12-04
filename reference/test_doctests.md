# Test doctests in a package

This is a utility function to run doctests in a local source package. It
calls
[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html).

## Usage

``` r
test_doctests(path = ".", ...)
```

## Arguments

- path:

  Path to package

- ...:

  Passed to
  [`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html).

## Value

The result of
[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html).

## Examples

``` r
if (FALSE) { # \dontrun{
  test_doctests()
} # }
```
