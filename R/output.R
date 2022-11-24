

#' @export
roclet_output.roclet_doctest <- function (x, results, base_path, ...) {
  results <- purrr::keep(results, "has_expectation")
  for (result in results) {
    filename <- test_file_name(result)
    write_test_file(filename, result$lines, base_path = base_path)
  }
}


write_test_file <- function (filename, contents, base_path) {
  if (! missing(base_path)) {
    test_path <- file.path(pkgload::pkg_path(base_path), "tests", "testthat")
    test_file_path <- file.path(test_path, filename)
  } else {
    # prints to stdout
    test_file_path <- ""
  }
  cat(contents, file = test_file_path, sep = "\n", append = FALSE)
}


test_file_name <- function (result) {
  sprintf("test-doctest-%s.R", result_name(result))
}
