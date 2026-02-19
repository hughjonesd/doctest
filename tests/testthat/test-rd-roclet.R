

test_that("Rd output", {
  ex <- "
         #' Title
         #'
         #' @doctest
         #' x <- 1
         #' @expect gt(0)
         #' x
         #' @expect lt(0)
         #' -x
         foo <- function() 1
        " |> dedent()

  results <- roc_proc_text(rd_roclet(), ex)
  expect_snapshot_output(
    print(results) # seems to work
  )

  ex_complex <- "
                 #' Title
                 #'
                 #' @doctest
                 #' x <- 1
                 #' if (x > 0) {
                 #' @expect gt(0)
                 #'   x
                 #' } else {
                 #' @expect lt(0)
                 #'   -x
                 #' }
                 foo <- function() 1
                " |> dedent()

  results <- roc_proc_text(rd_roclet(), ex_complex)
  expect_snapshot_output(
    print(results)
  )
})



test_that("@testRaw does not produce empty lines in Rd output", {
  ex <- "
         #' Title
         #'
         #' @doctest
         #' x <- 1
         #' @testRaw skip_on_cran()
         #' @expect gt(0)
         #' x
         foo <- function() 1
        " |> dedent()

  results <- roc_proc_text(rd_roclet(), ex)
  expect_snapshot_output(
    print(results)
  )
})


test_that("dontrun", {

  test_dontrun <- "
                   #' Title
                   #'
                   #' @doctest
                   #' \\dontrun{
                   #' @expect error(., 'foo')
                   #' stop('foo')
                   #' }
                   foo <- 1
                  " |> dedent()
  results <- roc_proc_text(rd_roclet(), test_dontrun)
  expect_snapshot_output(
    print(results)
  )
})


test_that("rd_roclet output", {
  r_file <- file.path("testPackage", "R", "safe-arithmetic.R")
  r_file_text <- readLines(r_file)

  roxygen2::load_options("testPackage")
  expect_silent(
      result <- roxygen2::parse_file(r_file)
  )

  expect_silent(
    result <- roxygen2::roc_proc_text(roxygen2::rd_roclet(), r_file_text)
  )

  setwd("testPackage")
  on.exit(setwd(".."))
  expect_no_error(
    suppressMessages(roxygen2::roxygenise(clean = TRUE))
   )

  expect_snapshot_file(file.path("man", "safe_mean.Rd"),
                       compare = compare_file_text)

  expect_snapshot_file(file.path("man", "palindrome.Rd"),
                       compare = compare_file_text)
})

