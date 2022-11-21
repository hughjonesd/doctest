
library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)


test_that("@testComments", {
  test_comment <- "
                   #' @examples
                   #' 1
                   #' @doctest
                   #' @testComments
                   #' a <- 1
                   #' # expect equal(a, 1)
                   #' # expect equal(., 4)
                   #' 2 + 2
                   NULL
                  " |> dedent()

  results <- roc_proc_text(dt_roclet(), test_comment)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  complex_test_comment <- "
                           #' @examples
                           #' 1
                           #' @doctest
                           #' @testComments
                           #' if (TRUE) {
                           #'   # expect equal(a, 1)
                           #'   # expect equal(., 4)
                           #'   2 + 2
                           #' } else {
                           #'   # expect gt(a, 0)
                           #'   # expect length(., 10)
                           #'   rnorm(10)
                           #' }
                           NULL
                          " |> dedent()

  results <- roc_proc_text(dt_roclet(), complex_test_comment)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  bad_test_comment <- "
                       #' @examples
                       #' 1
                       #' @doctest
                       #' @testComments
                       #'
                       #' a <- 1 # expect equal(a, 1)
                       NULL
                      " |> dedent()

  expect_error(
    roc_proc_text(dt_roclet(), bad_test_comment)
  )

  misplaced_dot_comment <- "
                           #' @examples
                           #' 1
                           #' @doctest
                           #' @testComments
                           #' if (TRUE) {
                           #'   # expect equal(., 4)
                           #' }
                           NULL
                          " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), misplaced_dot_comment)
  )

})
