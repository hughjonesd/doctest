#' Write testthat files using roxygen tags
#'
#' To use this, add
#' ```r
#' Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::doctest"))
#' ```
#' to your package DESCRIPTION file. Then run [roxygen2::roxygenize()] or
#' [devtools::document()] from the command line.
#'
#' doctest is `r lifecycle::badge("experimental")`.
#'
#' @keywords internal
#' @aliases NULL
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
#'     #'x <- 2 + 2
#'     #' @expect equals(x, 4)
#'     #'
#'     #' f <- function () warning("Watch out")
#'     #' @expect warning(f())
#'
#' Don't include the `expect_` prefix.
#'
#' Use a dot `.` to refer to the following expression:
#'
#'     @expect equals(., 4)
#'     2 + 2
#'
#' @name expect
#' @aliases @expect
NULL


#' Start a new test
#'
#' `@test` starts a new test.
#'
#' @details
#' By default, a test labelled "Example: &lt;object name&gt;" is created. Use
#' `@test` to create separate tests within a single example:
#'
#'     #' @examples
#'     #'
#'     #' x <- 1
#'     #' @expect equal(., x)
#'     #' abs(x)
#'     #'
#'     #' @test Negative numbers
#'     #' x <- -1
#'     #' @expect equal(., -x)
#'     #' abs(x)
#
#' @name test
#' @aliases @test
NULL



#' Exclude example code from a test
#'
#' `@skiptest` excludes the following code from a test. `@unskip` stops excluding
#' code.
#'
#' @details
#' Use these tags to avoid redundant or noisy code:
#'
#'     #' @examples
#'     #'
#'     #' @expect equal(., 0)
#'     #' sin(0)
#'     #'
#'     #' @skiptest
#'     #' curve(sin(x), 0, 2 * pi)
#'     #' @unskip
#'     #'
#'     #' @expect equal(., 1)
#'     #' cos(0)
#'
#' Remember that the main purpose of examples is to document your package for
#' your users. If your code is getting too different from your example, consider
#' splitting it off into a proper test file.
#'
#' @name skiptest
#' @aliases @skiptest @unskip
NULL
