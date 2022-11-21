

library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)


test_that("@expectRaw", {
  raw_expectation <- "
                      #' @examples
                      #' 1
                      #' @expectRaw equal(2 + 2, 4)
                      NULL
                     " |> dedent()
  results <- roc_proc_text(dt_roclet(), raw_expectation)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})

