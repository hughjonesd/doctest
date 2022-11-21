
library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)


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
  results <- roc_proc_text(doctest(), test_ex)
  expect_snapshot_output(
    roclet_output(doctest(), results)
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
    roc_proc_text(doctest(), test_bad_name)
  )
})
