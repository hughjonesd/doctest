
test_that("@expectation", {
  simple_expectation <-
"
#' @examples
#' 1
#' @expect equals(2)
#' sum(1, 1)
NULL
"
  results <- roxygen2::roc_proc_text(doctest::doctest(), simple_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  operator_expectation <-
"
#' @examples
#' 1
#' @expect equals(2)
#' 1 + 1
NULL
"
  results <- roxygen2::roc_proc_text(doctest::doctest(), operator_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  namespace_expectation <-
"
#' @examples
#' 1
#' @expect equals(2)
#' base::sum(1, 1)
NULL
"
  results <- roxygen2::roc_proc_text(doctest::doctest(), namespace_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )
})


test_that("@test", {
    test_ex <-
"
#' @examples
#' 1
#' @expect equals(2)
#' 2
#' @test three
#' @expect equals(3)
#' 3
NULL
"
  results <- roxygen2::roc_proc_text(doctest::doctest(), test_ex)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  test_bad_name <-
"
#' @examples
#' 1
#' @test three\" {warning('this would be sad');\"
#' @expect equals(3)
#' 3
NULL
"
  expect_error(
    roxygen2::roc_proc_text(doctest::doctest(), test_bad_name)
  )
})


test_that("@skiptest", {
  skiptest <-
"
#' @examples
#' a <- 1
#' @skiptest
#'
#' a <- 2
#' @unskip
#' @expect equals(1)
#' a
NULL
"
  results <- roxygen2::roc_proc_text(doctest::doctest(), skiptest)
  expect_output(
    roxygen2::roclet_output(doctest::doctest(), results),
    regexp = "a <- 1\\s+expect"
  )
})
