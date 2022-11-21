

library(roxygen2)
dedent <- function (x) gsub("\n\\s+", "\n", x)


test_that("@doctest", {
    test_ex <- "
                #' @doctest is 1 1?
                #' @expectRaw equal(1, 1)
                #'
                #' @doctest is TRUE true?
                #' @expect true()
                #' TRUE
                NULL
               " |> dedent()
  results <- roc_proc_text(dt_roclet(), test_ex)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )

  test_bad_name <- "
                    #' @doctest three\" {warning('this would be sad');\"
                    #' @expect equal(3)
                    #' 3
                    NULL
                   " |> dedent()
  expect_error(
    roc_proc_text(dt_roclet(), test_bad_name)
  )
})


test_that("dontrun", {

  test_dontrun <- "
                   #' @doctest
                   #' \\dontrun{
                   #' @expect error(., 'foo')
                   #' stop('foo')
                   #' }
                   NULL
                  " |> dedent()
  results <- roc_proc_text(dt_roclet(), test_dontrun)
  expect_snapshot_output(
    roclet_output(dt_roclet(), results)
  )
})
