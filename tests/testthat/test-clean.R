

test_that("roclet_clean", {
  setwd("testPackage")
  on.exit(setwd(".."))

  if (length(list.files("tests/testthat", pattern = "test-doctest")) == 0L) {
    suppressMessages(roxygenise(roclets = "doctest::dt_roclet"))
  }

  expect_message(
    roclet_clean(dt_roclet(), ".")
  )

  expect_length(
    list.files("tests/testthat", pattern = "test-doctest"),
    0L
  )

  expect_length(
    list.files("tests/testthat", pattern = "test-dont-delete"),
    1L
  )
})
