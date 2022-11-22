

#' @export
roclet_clean.roclet_doctest <- function (x, base_path) {
  test_dir <- file.path(base_path, "tests", "testthat")
  test_files <- list.files(test_dir, full.names = TRUE)

  test_files <- test_files[! file.info(test_files)$isdir]

  test_files <- purrr::keep(test_files, made_by_doctest)
  test_files <- purrr::keep(test_files,
                              \(f) grepl("^test-doctest-", basename(f))
                            )
  unlink(test_files)
}


made_by_doctest <- function (filepath) {
  any(grepl(doctest_stamp(), readLines(filepath), fixed = TRUE))
}
