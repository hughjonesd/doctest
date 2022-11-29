
library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)

# donttest/run/show

test_that("@examples tag", {
  examples_expectation <- "
                           #' @examples
                           #' 1
                           #' @doctest
                           #' @snap
                           #' sum(1, 1)
                           NULL
                          " |> dedent()

  expect_warning({
    results <- roc_proc_text(dt_roclet(), examples_expectation)
  }, "@examples")
})



test_that("Tags outside @doctest", {
  outside_expectation <- "
                          #' @expect true()
                          #' TRUE
                          #' @doctest
                          NULL
                         " |> dedent()

  expect_warning({
    results <- roc_proc_text(dt_roclet(), outside_expectation)
  }, "@doctest")
})


test_that("assignment", {
  assignment_expectation <- "
                             #' @doctest
                             #' @expect equal(1)
                             #' x <- 1
                             NULL
                            " |> dedent()

  results <- roc_proc_text(dt_roclet(), assignment_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})



test_that("assignment with dot", {
  assignment_dot_expectation <- "
                                 #' @doctest
                                 #' @expect equal(x <- ., rev(x))
                                 #' c('t', 'e', 'n', 'e', 't')
                                 NULL
                                " |> dedent()

  results <- roc_proc_text(dt_roclet(), assignment_dot_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})


test_that("comment", {
  comment_expectation <- "
                          #' @doctest
                          #' @expect equal(4)
                          #' # comment in the way
                          #' 2 + 2
                          NULL
                         " |> dedent()

  results <- roc_proc_text(dt_roclet(), comment_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})



test_that("Multiple @doctest tags", {
  multi_doctest_expectation <- "
                                #' @doctest
                                #' @expect equal(1)
                                #' x <- 1
                                #' @export
                                #' @doctest
                                #' @expect equal(4)
                                #' 2 + 2
                                NULL
                               " |> dedent()

  results <- roc_proc_text(dt_roclet(), multi_doctest_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})



test_that("Multiple @doctest tags, invalid syntax", {
  bad_multi_doctest <- "
                        #' @doctest
                        #' if (TRUE) {
                        #' @expect equal(4)
                        #' 2 + 2
                        #' } else {
                        #' @doctest
                        #' @expect equal(4)
                        #' 2 + 2
                        #' }
                        NULL
                       " |> dedent()

  expect_error(
    roc_proc_text(dt_roclet(), bad_multi_doctest)
  )
})
