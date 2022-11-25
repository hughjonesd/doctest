

#' @export
roclet_output.roclet_doctest <- function (x, results, base_path, ...) {
  results <- purrr::keep(results, "has_expectation")
  filenames <- purrr::map_chr(results, test_file_name)
  lines_list <- purrr::map(results, "lines")
  purrr::walk2(filenames, lines_list, write_test_file, base_path = base_path)

  if (! missing(base_path)) {
    old_filenames <- doctest_test_files(base_path)
    old_filenames <- setdiff(old_filenames, filenames)
    old_filepaths <- file.path(package_test_path(base_path), old_filenames)
    old_filepaths <- purrr::keep(old_filepaths, made_by_doctest)
    warn_and_unlink(old_filepaths)
  }
}


#' @export
roclet_clean.roclet_doctest <- function (x, base_path) {
  test_files <- doctest_test_files(base_path)
  test_filepaths <- file.path(package_test_path(base_path), test_files)
  test_filepaths <- purrr::keep(test_filepaths, made_by_doctest)
  warn_and_unlink(test_filepaths)
}


warn_and_unlink <- function (paths) {
  for (path in paths) {
    cli::cli_inform("Deleting {.file {basename(path)}}")
    unlink(path)
  }
}


made_by_doctest <- function (filepath) {
  any(grepl(doctest_stamp(), readLines(filepath), fixed = TRUE))
}


doctest_test_files <- function (base_path) {
  test_path <- package_test_path(base_path)
  test_files <- list.files(test_path, pattern = "^test-doctest-.*\\.[rR]$",
                           full.names = FALSE)

  test_files
}


package_test_path <- function (base_path) {
  test_path <- file.path(pkgload::pkg_path(base_path), "tests", "testthat")
}


write_test_file <- function (filename, contents, base_path) {
  if (! missing(base_path)) {
    test_path <- package_test_path(base_path)
    test_file_path <- file.path(test_path, filename)

    cli::cli_inform(
      "Writing {.href [{filename}](file://{test_file_path})}")
  } else {
    # prints to stdout
    test_file_path <- ""
  }

  cat(contents, file = test_file_path, sep = "\n", append = FALSE)
}


test_file_name <- function (result) {
  sprintf("test-doctest-%s.R", result_name(result))
}
