

test_that("rd_roclet", {
  r_file <- file.path("testPackage", "R", "safe-arithmetic.R")
  r_file_text <- readLines(r_file)

  roxygen2::load_options("testPackage")
  expect_silent(
      result <- roxygen2::parse_file(r_file)
  )

  expect_silent(
    roxygen2::roc_proc_text(roxygen2::rd_roclet(), r_file_text)
  )
})
