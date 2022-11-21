#' Write testthat files using roxygen tags
#'
#' To use doctest in your package, add
#' ```r
#' Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::dt_roclet"))
#' ```
#' to the DESCRIPTION file. You may also optionally
#' add doctest to your 'Suggests:' dependencies.
#'
#' Then run [roxygen2::roxygenize()] or [devtools::document()] from the
#' command line.
#'
#' Doctest is `r lifecycle::badge("experimental")`.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL


#' Create an expectation
#'
#' `@expect` creates an expectation for your example code.
#'
#' @details
#' Use `@expect` to create a testthat expectation.
#'
#'     #' @examples
#'     #'
#'     #' @expect equals(4)
#'     #' 2 + 2
#'     #'
#'     #' f <- function () warning("Watch out")
#'     #' @expect warning()
#'     #' f()
#'
#' The next expression will be inserted as the first
#' argument to the `expect_*` call.
#'
#' Don't include the `expect_` prefix.
#'
#' If you want to include the expression in a different
#' place or places, use a dot `.`:
#'
#'     @expect equals(., rev(.))
#'     c("T", "E", "N", "E", "T")
#'
#' @name expect-tag
#' @aliases @expect
NULL


#' Create an expectation as-is
#'
#' `@expect` creates an expectation for your example code.
#'
#' @details
#' `@expectRaw` creates a testthat expectation. Unlike [@expect], it doesn't
#' insert the next expression:
#'
#'     #' @examples
#'     #'
#'     #'x <- 2 + 2
#'     #' @expectRaw equals(x, 4)
#'     #'
#'     #' f <- function () warning("Watch out")
#'     #' @expectRaw warning(f())
#'
#' Don't include the `expect_` prefix.
#'
#' @name expectRaw-tag
#' @aliases @expectRaw
NULL


#' Start a new test
#'
#' `@doctest` starts a new test.
#'
#' @details
#' By default, a test labelled "Example: &lt;object name&gt;" is created. Use
#' `@doctest` to create separate tests within a single example:
#'
#'     #' @examples
#'     #'
#'     #' x <- 1
#'     #' @expect equal(x)
#'     #' abs(x)
#'     #'
#'     #' @doctest Negative numbers
#'     #' x <- -1
#'     #' @expect equal(-x)
#'     #' abs(x)
#
#' @name doctest-tag
#' @aliases @doctest
NULL


#' Exclude example code from a test
#'
#' `@skipTest` excludes the following code from a test. `@resumeTest` stops excluding
#' code.
#'
#' @details
#' Use these tags to avoid redundant or noisy code:
#'
#'     #' @examples
#'     #'
#'     #' @expect equal(0)
#'     #' sin(0)
#'     #'
#'     #' @skipTest
#'     #' curve(sin(x), 0, 2 * pi)
#'     #' @resumeTest
#'     #'
#'     #' @expect equal(1)
#'     #' cos(0)
#'
#' Remember that the main purpose of examples is to document your package for
#' your users. If your code is getting too different from your example, consider
#' splitting it off into a proper test file.
#'
#' @name skipTest-tag
#' @aliases @skipTest @resumeTest
NULL


#' Write expectations in comments
#'
#' `@testComments` lets you write expectations in comments.
#' This may be useful if you have complex examples with `if` statements or
#' `for` loops
#'
#' @details
#' Doctests like this won't work, because the test tags split up the example
#' code so that roxygen can't parse it.
#'
#'     #' @examples
#'     #'
#'     #' if (x > 0) {
#'     #'   @expect gt(0)
#'     #'   x
#'     #'   print("x is positive')
#'     #' } else {
#'     #'   @expect lt(0)
#'     #'   x
#'     #'   print("x is negative')
#'     #' }
#'
#' As an alternative, put `@testComments` in your examples section and write
#' expectations in comments:
#'
#'     #' @examples
#'     #' @testComments
#'     #' if (x > 0) {
#'     #'   # expect gt(0)
#'     #'   x
#'     #'   print("x is positive")
#'     #' } else {
#'     #'   # expect lt(0)
#'     #'   x
#'     #'   print("x is negative")
#'     #' }
#'
#' Expectations in comments match the format of [@expect] tags, but with a
#' comment character `#` in place of the `@`.
#'
#' Comments should be on their own line, with no other code:
#'
#'     #' # Wrong:
#'     #' x <- 2 + 2 # expectRaw equal(x, 4)
#'     #'
#'     #' # Right:
#'     #' # expect equal(4)
#'     #' 2 + 2
#'     #'
#'     #' # Right:
#'     #' x <- 2 + 2
#'     #' # expectRaw equal(x, 4)
#'
#' You can only use `expect` and `expectRaw`, not any other tags.
#' Comments will remain visible in the example.
#'
#' @name testComments-tag
#' @aliases @testComments
NULL
