

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

  expect_no_error(
    suppressMessages(roxygen2::roxygenise("testPackage"))
  )

  expect_snapshot_file(file.path("testPackage", "man", "safe_mean.Rd"),
                       compare = compare_file_text)

  expect_snapshot_file(file.path("testPackage", "man", "safe_mean.Rd"),
                       compare = compare_file_text)
})
