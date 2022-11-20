
<!-- README.md is generated from README.Rmd. Please edit that file -->

# doctest

<!-- badges: start -->

[![R-CMD-check](https://github.com/hughjonesd/doctest/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hughjonesd/doctest/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Doctests are documentation combined with tests. The doctest package
helps you write [testthat](https://testthat.r-lib.org/) doctests, by
adding tags to your [roxygen](https://roxygen2.r-lib.org/)
documentation.

`R CMD CHECK` already checks examples, but it only confirms that they
run. Using doctest, you can also make sure that examples do what they
are supposed to do.

The [roxytest](https://mikldk.github.io/roxytest/) package is another
way you can write tests in roxygen. doctests aims to be slightly less
verbose.

## Example

Here’s some documentation for a function:

``` r

#' Safe mean
#' 
#' @param x Numeric vector
#' @export
#' 
#' @examples
#' 
#' x <- safe_mean(1:3)
#' @expect equal(x, 2)
#' 
#' @expect warning(., "not numeric")
#' safe_mean("a")
#'
#' @expect warning(., "NA elements")
#' safe_mean(c(1, NA))
safe_mean <- function (x) {
  if (! is.numeric(x)) warning("x is not numeric")
  if (any(is.na(x))) warning("x contains NA elements")
  mean(x)
}
```

This will create tests like:

    #> 
    #> # File test-examples-safe_mean.R
    #> # Generated by doctest: do not edit by hand
    #> 
    #> test_that("Example: safe_mean", {
    #> # Created from @examples for `safe_mean`
    #> # Source file: '<text>'
    #> # Source line: 7
    #>   x <- safe_mean(1:3)
    #>   expect_equal(x, 2)
    #>   expect_warning(safe_mean("a"), "not numeric")
    #>   expect_warning(safe_mean(c(1, NA)), "NA elements")
    #> })

The .Rd file will be created as normal, with an example section like:

    \examples{
    safe_mean(x)
    safe_mean("a")
    safe_mean(c(1, NA))
    }

## Usage

You can install the development version of doctest like this:

``` r
devtools::install("hughjonesd/doctest")
```

To use doctest, put a line in your package DESCRIPTION to add the
`doctest` roclet to roxygen, like this:

    Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::doctest")) 

Then in the package directory run:

``` r
roxygen2::roxygenize()
```

as normal to create documentation. This will also create tests in
`tests/testthat`, named `test-example-xxx.R`. One file is created for
each example.

At present, you can’t use doctest from the RStudio keyboard shortcut
`Ctrl + Shift + D`, because this always uses the standard roxygen2
roclets. However, you can bind the RStudio addin “Devtools: document a
package” to a keyboard shortcut. This will use the roclets from your
package DESCRIPTION file.

## doctest tags

The doctest package adds four tags to roxygen:

### `@expect`

`@expect` writes a testthat expectation.

``` r
#'
#' @expect equal(1 + 1, 2)
```

You can use any `expect_*` function from `testthat`. Omit the `expect_`
at the start.

Use a dot `.` to substitute for the expression below:

``` r
#' @expect equal(., 4)
#' 2+2
#'
#' @expect equal(., rev(.))
#' c("T", "E", "N", "E", "T")
```

### `@test`

By default, all expectations are created in a single test, named after
the example. `@test <test-name>` changes to a new test.

``` r
#' @test Negative numbers
#' @expect gt(0)
#' abs(-1)
```

### `@skiptest` and `@unskip`

By default, the test uses the whole example, since example code may
depend on previous code.

`@skiptest` omits lines of the example from the test. `@unskip` stops
omitting lines. You can use this to skip irrelevant material.

``` r
#' @skiptest
#' # No need to test plotting
#' plot(1:10, my_func(1:10))
#' @unskip
```

## How to use doctest

doctest is best used for relatively simple tests. If things get too
complex it may be better to write a test yourself. I like the following
advice:

> … write the best possible documentation, and \[R\] makes sure the code
> samples in your documentation actually compile and run \[and do what
> they are supposed to do\]

*Programming Rust*, Blandy, Orendorff and Tindall, 2021

## Bugs

### Empty `@examples` section

Roxygen may produce a warning like `@examples requires a value`. This is
harmless. To avoid it, put some R code in your `@examples` section
before the first `@expectation` or other tag.

### `donttest` and `dontrun`

`donttest` and `dontrun` Rd tags are ignored by doctest. This lets you
test code that would fail when run by R CMD CHECK. Howeer, these tags
must not span more than one doctest tag. For example, this will work:

``` r
#' @expect error("argh")
#' \dontrun{
#' stop("argh")
#' }
```

But this won’t, because it contains a doctest tag:

``` r
#' \dontrun{
#' @expect error("argh")
#' stop("argh")
#' }
```
