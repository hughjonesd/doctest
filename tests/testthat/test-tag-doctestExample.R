

test_that("@doctestExample", {
  test_ex <- "
              #' Title
              #'
              #' @doctest example from a file
              #' @expect equal(2)
              #' 1 + 1
              #' @doctestExample doctestExample-tester.R
              foo <- function () 1
             " |> dedent()
  results <- roc_proc_text(dt_roclet(), test_ex)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  rd_results <- roc_proc_text(rd_roclet(), test_ex)
  expect_snapshot_output(
    print(rd_results)
  )
})
