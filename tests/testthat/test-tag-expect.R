

test_that("@expectation", {
  simple_expectation <- "
                         #' @doctest
                         #' @expect equal(2)
                         #' sum(1, 1)
                         NULL
                        " |> dedent()
  results <- roc_proc_text(dt_roclet(), simple_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  dot_expectation <- "
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
                            #' @doctest
                            #' @expect equal(., 2)
                            #' base::sum(1, 1)
                            NULL
                           " |> dedent()
  results <- roc_proc_text(dt_roclet(), namespace_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  donttest_expectation <- "
                           #' @doctest
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
                                  #' @doctest
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
                              #' @doctest
                              #' @expect equal(4)
                              NULL
                             " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), no_follower_expectation)
  )

  no_follower_dot_expectation <- "
                                  #' @doctest
                                  #' @expect equal(., 4)
                                  NULL
                                 " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), no_follower_dot_expectation)
  )
})
