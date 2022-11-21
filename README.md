
<!-- README.md is generated from README.Rmd. Please edit that file -->

# doctest

<!-- badges: start -->

[![R-CMD-check](https://github.com/hughjonesd/doctest/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hughjonesd/doctest/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Documentation examples and tests share certain features. They are both
usually self-contained pieces of code. They should cover the software’s
most important functions and typical uses. They should both be simple
and clear: complex examples are hard for users to understand, and
complex test code can introduce testing bugs. This similarity makes it
attractive to use “doctests”, which provide both documentation and
testing. Indeed, several languages, including Python and Rust, have
doctests built in.[^1] R also checks for errors in examples when running
`R CMD check`.

The doctest package extends this idea. It lets you write
[testthat](https://testthat.r-lib.org/) tests, by adding tags to your
[roxygen](https://roxygen2.r-lib.org/) documentation. So, as well as
checking that your examples run, you can also check they do what they
are supposed to do.

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

    #> \examples{
    #> 
    #> x <- safe_mean(1:3)
    #> safe_mean("a")
    #> safe_mean(c(1, NA))
    #> }

## Usage

You can install the development version of doctest like this:

``` r
devtools::install("hughjonesd/doctest")
```

To use doctest, alter your package DESCRIPTION to add the `doctest`
roclet to roxygen, like this:

    Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::doctest")) 

You can also add `doctest` as a dependency:

``` r
usethis::use_dev_package("doctest", type = "Suggests", 
                         remote = "hughjonesd/doctest")
```

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

The doctest package adds five tags to roxygen:

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
#' @expect gt(., 0)
#' abs(-1)
```

### `@skipTest` and `@resumeTest`

By default, the test uses the whole example, since example code may
depend on previous code.

`@skipTest` omits lines of the example from the test. `@resumeTest`
stops omitting lines. You can use this to skip irrelevant material.

``` r
#' @skipTest
#' # No need to test plotting
#' plot(1:10, my_func(1:10))
#' @resumeTest
```

### `@testComments`

Because of how roxygen works, you can’t add expectations in the middle
of complex expressions like `if` statements or `for` loops. For example,
this won’t work:

``` r
#' if (x > 0) {
#'   @expect gt(x, 0)
#' } else {
#'   @expect lt(x, 0)
#' }
```

As an alternative, you can use the `@testComments` tag to test
expectations in comments:

``` r
#' @testComments
#' if (x > 0) {
#'   # expect gt(x, 0)
#' } else {
#'   # expect lt(x, 0)
#' }
```

Doctest comments follow the same format as the expectation tag, but with
`@expect` replaced by `# expect`. Comments must be on their own line,
and will remain in the example code.

## How to use doctest

doctest is best used for relatively simple tests. If things get too
complex it may be better to write a test yourself. I like the following
advice:

> … write the best possible documentation, and \[R\] makes sure the code
> samples in your documentation actually compile and run \[and do what
> they are supposed to do\]

*Programming Rust*, Blandy, Orendorff and Tindall, 2021

## Bugs and limitations

### Empty `@examples` section

Roxygen may produce a warning like `@examples requires a value`. This is
harmless. To avoid it, put some R code in your `@examples` section
before the first `@expectation` or other tag.

### `donttest` and `dontrun`

`donttest` and `dontrun` Rd tags are ignored by doctest. This lets you
test code that would fail when run by R CMD CHECK. Howeer, these tags
must not span more than one doctest tag. For example, this will work:

``` r
#' @expect error(., "argh")
#' \dontrun{
#' stop("argh")
#' }
```

But this won’t, because it contains a doctest tag:

``` r
#' \dontrun{
#' @expect error(., "argh")
#' stop("argh")
#' }
```

You can work around this by using the `@testComments` tag and writing
expectations as comments.

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
