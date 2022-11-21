
library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)


test_that("@skipTest", {
  skip_test <- "
               #' @examples
               #' a <- 1
               #' @skipTest
               #'
               #' a <- 2
               #' @resumeTest
               #' @expect equal(., 1)
               #' a
               NULL
              " |> dedent()
  results <- roc_proc_text(doctest(), skip_test)
  expect_output(
    roclet_output(doctest(), results),
    regexp = "a <- 1\\s+expect"
  )
})
