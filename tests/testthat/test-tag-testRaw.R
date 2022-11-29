

test_that("@testRaw", {
  raw_expectation <- "
                      #' @doctest
                      #' @testRaw skip_on_cran()
                      #' @expect error()
                      #' stop(\"Argh, CRAN won't like it\")
                      NULL
                     " |> dedent()
  results <- roc_proc_text(dt_roclet(), raw_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})

