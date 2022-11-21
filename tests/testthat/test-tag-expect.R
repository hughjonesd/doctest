
library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)

test_that("@expectation", {
  simple_expectation <- "
                         #' @examples
                         #' 1
                         #' @expect equal(2)
                         #' sum(1, 1)
                         NULL
                        " |> dedent()
  results <- roc_proc_text(dt_roclet(), simple_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  dot_expectation <- "
                      #' @examples
                      #' 1
                      #' @doctest
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
                           #' @doctest
                           #' @expect equal( 2)
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
<<<<<<< HEAD
                            #' @expect equal(2)
=======
                            #' @doctest
                            #' @expect equal(., 2)
>>>>>>> Require @doctest before any expectations
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
<<<<<<< HEAD
                           #' @expect equal(2)
=======
                           #' @doctest
                           #' @expect equal(., 2)
>>>>>>> Require @doctest before any expectations
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
                                  #' 1
                                  #' @doctest
                                  #' 1 %plus% 1
                                  #' @expect equal(4)
                                  #' 2 %plus% 2
                                  NULL
                                 " |> dedent()

  results <- roc_proc_text(dt_roclet(),
                                     custom_operator_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )


  no_follower_expectation <- "
                                #' @examples
                                #' 1
                                #' @doctest
                                #' @expect equal(4)
                                NULL
                               " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), no_follower_expectation)
  )

  no_follower_dot_expectation <- "
                                  #' @examples
                                  #' 1
                                  #' @expect equal(., 4)
                                  NULL
                                 " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), no_follower_dot_expectation)
  )
})
