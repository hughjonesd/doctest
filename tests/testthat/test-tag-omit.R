

test_that("@omit", {
  skip_test <- "
                #' @doctest
                #' a <- 1
                #' @omit
                #'
                #' a <- 2
                #' @resume
                #' @expect equal(., 1)
                #' a
                NULL
               " |> dedent()
  results <- roc_proc_text(dt_roclet(), skip_test)
  expect_output(
    roclet_output(dt_roclet(), results),
    regexp = "a <- 1\\s+expect"
  )
})
