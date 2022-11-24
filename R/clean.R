

#' @export
roclet_clean.roclet_doctest <- function (x, base_path) {
  test_path <- file.path(base_path, "tests", "testthat")
  test_files <- list.files(test_path, pattern = "^test-doctest-.*\\.[rR]$",
                           full.names = TRUE)
  test_files <- purrr::keep(test_files, made_by_doctest)

  unlink(test_files)
}


made_by_doctest <- function (filepath) {
  any(grepl(doctest_stamp(), readLines(filepath), fixed = TRUE))
}
