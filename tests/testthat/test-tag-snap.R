

test_that("@snap", {
  snap_expectation <- "
                       #' @doctest
                       #' @snap
                       #' sum(1, 1)
                       NULL
                      " |> dedent()
  results <- roc_proc_text(dt_roclet(), snap_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})
