
dedent <- function (x) gsub("\n\\s+", "\n", x)

test_that("@expectation", {
  dot_expectation <- "
                      #' @examples
                      #' 1
                      #' @expect equal(., 2)
                      #' sum(1, 1)
                      NULL
                     " |> dedent()
  results <- roxygen2::roc_proc_text(doctest::doctest(), dot_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  operator_expectation <- "
                           #' @examples
                           #' 1
                           #' @expect equal(., 2)
                           #' 1 + 1
                           NULL
                          " |> dedent()
  results <- roxygen2::roc_proc_text(doctest::doctest(), operator_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  namespace_expectation <- "
                            #' @examples
                            #' 1
                            #' @expect equal(., 2)
                            #' base::sum(1, 1)
                            NULL
                           " |> dedent()
  results <- roxygen2::roc_proc_text(doctest::doctest(), namespace_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
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

  results <- roxygen2::roc_proc_text(doctest::doctest(), donttest_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  custom_operator_expectation <- "
                                  #' @examples
                                  #' 1 %plus% 1
                                  #' @expect equal(., 4)
                                  #' 2 %plus% 2
                                  NULL
                                 " |> dedent()

  results <- roxygen2::roc_proc_text(doctest::doctest(),
                                     custom_operator_expectation)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

})

test_that("@test", {
    test_ex <- "
                #' @examples
                #' 1
                #' @expect equal(1, 1)
                #'
                #' @test is TRUE true?
                #' @expect true(TRUE)
                NULL
               " |> dedent()
  results <- roxygen2::roc_proc_text(doctest::doctest(), test_ex)
  expect_snapshot_output(
    roxygen2::roclet_output(doctest::doctest(), results)
  )

  test_bad_name <- "
                    #' @examples
                    #' 1
                    #' @test three\" {warning('this would be sad');\"
                    #' @expect equal(., 3)
                    #' 3
                    NULL
                   " |> dedent()
  expect_error(
    roxygen2::roc_proc_text(doctest::doctest(), test_bad_name)
  )
})


test_that("@skiptest", {
  skiptest <- "
               #' @examples
               #' a <- 1
               #' @skiptest
               #'
               #' a <- 2
               #' @unskip
               #' @expect equal(., 1)
               #' a
               NULL
              " |> dedent()
  results <- roxygen2::roc_proc_text(doctest::doctest(), skiptest)
  expect_output(
    roxygen2::roclet_output(doctest::doctest(), results),
    regexp = "a <- 1\\s+expect"
  )
})
