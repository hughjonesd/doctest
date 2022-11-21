
library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)

test_that("@expectation", {
  dot_expectation <- "
                      #' @examples
                      #' 1
                      #' @expect equal(., 2)
                      #' sum(1, 1)
                      NULL
                     " |> dedent()
  results <- roc_proc_text(dt_roclet(), dot_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  operator_expectation <- "
                           #' @examples
                           #' 1
                           #' @expect equal(., 2)
                           #' 1 + 1
                           NULL
                          " |> dedent()
  results <- roc_proc_text(dt_roclet(), operator_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  namespace_expectation <- "
                            #' @examples
                            #' 1
                            #' @expect equal(., 2)
                            #' base::sum(1, 1)
                            NULL
                           " |> dedent()
  results <- roc_proc_text(dt_roclet(), namespace_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  donttest_expectation <- "
                           #' @examples
                           #' 1
                           #' @expect equal(., 2)
                           #' \\donttest{
                           #' sum(1, 1)
                           #' }
                           NULL
                          " |> dedent()

  results <- roc_proc_text(dt_roclet(), donttest_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  custom_operator_expectation <- "
                                  #' @examples
                                  #' 1 %plus% 1
                                  #' @expect equal(., 4)
                                  #' 2 %plus% 2
                                  NULL
                                 " |> dedent()

  results <- roc_proc_text(dt_roclet(),
                                     custom_operator_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )


  misplaced_dot_expectation <- "
                                #' @examples
                                #' 1
                                #' @expect equal(., 4)
                                NULL
                               " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), misplaced_dot_expectation)
  )
})
