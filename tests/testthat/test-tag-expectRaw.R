

test_that("@expectRaw", {
  raw_expectation <- "
                      #' @doctest
                      #' @expectRaw equal(2 + 2, 4)
                      NULL
                     " |> dedent()
  results <- roc_proc_text(dt_roclet(), raw_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})
