
<!-- README.md is generated from README.Rmd. Please edit that file -->

# doctest

<!-- badges: start -->

[![R-CMD-check](https://github.com/hughjonesd/doctest/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hughjonesd/doctest/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Documentation examples and tests are similar in some ways:

- They are self-contained pieces of code.

- They should cover the software’s most important functions and typical
  uses.

- They should be simple and clear: complex examples are hard for users
  to understand, and complex test code can introduce testing bugs.

This similarity makes it attractive to use “doctests”, which combine
tests and documentation. Indeed, several languages, including Python and
Rust, have doctests built in.[^1] R also checks for errors in examples
when running `R CMD check`.

The doctest package extends this idea. It lets you write
[testthat](https://testthat.r-lib.org/) tests, by adding tags to your
[roxygen](https://roxygen2.r-lib.org/) documentation. This helps you
check that your examples do what they are supposed to do.

## Example

Here’s some [roxygen](https://roxygen2.r-lib.org) documentation for a
function:

``` r

#' Safe mean
#' 
#' @param x Numeric vector
#' @return The mean of `x`
#' 
#' @doctest
#' @expect equal(2)
#' safe_mean(1:3)
#' 
#' @expect warning("not numeric")
#' safe_mean("a")
#'
#' @expect warning("NA elements")
#' safe_mean(c(1, NA))
safe_mean <- function (x) {
  if (! is.numeric(x)) warning("x is not numeric")
  if (any(is.na(x))) warning("x contains NA elements")
  mean(x)
}
```

Instead of an `@examples` section, we have a `@doctest` section.

This will create tests like:

    # Generated by doctest: do not edit by hand
    # Please edit file in R/<text>

    test_that("Example: safe_mean", {
      # Created from @doctest for `safe_mean`
      # Source file: <text>
      # Source line: 7
      expect_equal(safe_mean(1:3), 2)
      expect_warning(safe_mean("a"), "not numeric")
      expect_warning(safe_mean(c(1, NA)), "NA elements")
    })

The .Rd file will be created as normal, with an example section like:

    \examples{
    safe_mean(1:3)
    safe_mean("a")
    safe_mean(c(1, NA))
    }

## Usage

You can install the development version of doctest like this:

``` r
devtools::install("hughjonesd/doctest")
```

Here’s a simple workflow to start using doctest:

1.  Alter your package DESCRIPTION to add the `doctest` roclet to
    roxygen:

<!-- -->

    Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::dt_roclet")) 

You can also add `doctest` as a dependency:

``` r
usethis::use_dev_package("doctest", type = "Suggests", 
                       remote = "hughjonesd/doctest")
```

2.  In your roxygen documentation, replace `@examples` by `@doctest`.

3.  In the package directory run `roxygen2::roxygenize()` or
    `devtools::document()` to create documentation. You will see new
    files labelled `test-doctest-<topic>.R` in the `tests/testthat`
    directory. You should also see Rd files created as normal in the
    `man/` directory, including `\examples` sections.

4.  Add `@expect` tags to your `@doctest` sections.

5.  Run `roxygenize()` again. Your tests will be recreated with new
    expectations.

6.  Run `devtools::test()` and check that your tests pass.

At present, you can’t use doctest from the RStudio keyboard shortcut
`Ctrl + Shift + D`, because this always uses the standard roxygen2
roclets. However, you can bind the RStudio addin “Devtools: document a
package” to a keyboard shortcut. This will use the roclets from your
package DESCRIPTION file.

## doctest tags

The doctest package adds five tags to roxygen:

### `@doctest`

Use `@doctest` instead of `@examples`:

``` r
#' @doctest
#' 
#' # ... examples for your function
```

The content of `@doctest` will be used in the .Rd “examples” section,
and in a testthat test.

You can have more than one `@doctest` section. Each section creates one
test like `test_that("Test name", {...})`. You can name the doctest, or
leave it blank for a default name. All the sections will be merged into
a single .Rd example.

``` r
#' @doctest Positive numbers
#' x <- 1
#' @expect equal(x)
#' abs(x)
#'
#' @doctest Negative numbers
#' x <- -1
#' @expect equal(-x)
#' abs(x)
```

### `@expect`

`@expect` writes a testthat expectation.

``` r
#' @expect equal(4)
#' 2 + 2
```

You can use any `expect_*` function from `testthat`. Omit the `expect_`
at the start of the call.

The expression on the next line will be substituted as the first
argument into the `expect` call:

``` r
expect_equal(2 + 2, 4)
```

Use a dot `.` to substitute in different places:

``` r
#' @expect equal(., rev(.))
#' c("T", "E", "N", "E", "T")
```

becomes:

``` r
expect_equal(c("T", "E", "N", "E", "T"), rev(c("T", "E", "N", "E", "T")))
```

### `@expectRaw`

`@expectRaw` writes an expectation, without substituting the next
expression:

``` r
#' x <- 2 + 2
#' @expectRaw equal(x, 4)
```

### `@pause` and `@resume`

By default, the doctest uses the whole example. `@pause` stops including
the example in the doctest until the next expectation or other tag. You
can use `@resume` to restart including lines without creating a new
expectation.

``` r
#' myfunc(1)
#' 
#' @pause
#' # No need to test plotting
#' plot(1:10, my_func(1:10))
#' 
#' @resume
#' x <- NA
#' @expect warning()
#' myfunc(x)
```

## Writing good doctests

Tests and documentation are similar, but not identical. Tests need to
cover difficult corner cases. Examples need to convey the basics to the
user. I like the following advice:

> … write the best possible documentation, and \[R\] makes sure the code
> samples in your documentation actually compile and run \[and do what
> they are supposed to do\]

*Programming Rust*, Blandy, Orendorff and Tindall, 2021

In particular, use doctest as an *addition* to manually created tests,
not a *substitute* for them. Use doctest for relatively simple tests of
basic functionality. If it’s hard to specify what to test for, consider
using `testthat::expect_snapshot()` to capture output. For more complex
test cases, write a test file manually.

``` r
#' @expect snapshot()
summary(model)
```

## Related packages

The [roxytest](https://mikldk.github.io/roxytest/) and
[roxut](https://github.com/bryanhanson/roxut) packages both allow you to
write tests in roxygen blocks. Doctest is slightly different because it
combines tests with examples. The
[exampletestr](https://github.com/rorynolan/exampletestr/) package uses
roxygen examples to generate a test skeleton which you can fill in
yourself.

[^1]: <https://docs.python.org/3/library/doctest.html>,
    <https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html>
