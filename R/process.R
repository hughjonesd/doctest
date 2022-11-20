

#' Create doctests from roxygen tags
#'
#' @return The doctest roclet
#' @export
#' @seealso Package documentation at [doctest-package]
#' @examples
#' \dontrun{
#' roxygen2::roxygenize(roclets = "doctest::doctest")
#' }
doctest <- function () {
  roxygen2::roclet("doctest")
}


#' @export
roclet_process.roclet_doctest <- function (x, blocks, env, base_path) {
  results <- lapply(blocks, build_result_from_block)
  results <- purrr::compact(results)

  results
}


build_result_from_block <- function (block) {
  if (! roxygen2::block_has_tags(block, c("expect", "test"))) return(NULL)

  tags <- roxygen2::block_get_tags(block, c("expect", "examples", "test"))

  result <- structure(list(tests = list()), class = "doctest_result")

  result$file <- basename(block$file)
  result$object <- block_name(block)

  test <- new_test(
                   name = sprintf("Example: %s", result$object),
                   source_object = result$object,
                   source_file = tags[[1]]$file,
                   source_line = tags[[1]]$line
                   )
  for (tag in tags) {
    if (inherits(tag, "roxy_tag_test")) {
      # create expectations
      result <- add_test_to_result(test, result)
      test <- new_test(
                       name = tag$doctest_test_name,
                       source_object = result$object,
                       source_file = tag$file,
                       source_line = tag$line
                       )
    } else {
      test <- add_tag_to_test(tag, test)
    }
  }
  result <- add_test_to_result(test, result)

  result
}


block_name <- function (block) {
  name_tag <- roxygen2::block_get_tag(block, "name")
  block$object$alias %||% name_tag$val %||% "unknown"
}


result_name <- function(result) {
  result$object %||% "unknown"
}


new_test <- function (name, source_object, source_file, source_line) {
  if (grepl("\"|\\\\", name)) {
    cli::cli_abort(c(
      "@test name must not include double quotes or backslashes",
      x = "Name was {.code {name}}"
    ))
  }

  source_file <- fs::path_rel(source_file, pkgload::pkg_path())
  structure(list(
                 name          = name,
                 source_object = source_object,
                 source_file   = source_file,
                 source_line   = source_line,
                 lines         = character(0)
                ),
            class = "doctest_test")
}


add_tag_to_test <- function (tag, test) UseMethod("add_tag_to_test", tag)


add_tag_to_test.roxy_tag_expect <- function (tag, test, ...) {
  # we put the expectation back, because we have to get rid of
  # \donttest etc.
  # we use .doctest_expect_ as a string to search for
  expect_line <- sprintf(".doctest_expect_%s", tag$doctest_expect)
  test$lines <- c(test$lines, expect_line)
  test <- add_lines_to_test(tag, test)

  test
}


add_tag_to_test.roxy_tag_examples <- function (tag, test, ...) {
  add_lines_to_test(tag, test)
}


add_tag_to_test.roxy_tag_unskip <- add_tag_to_test.roxy_tag_examples


add_tag_to_test.roxy_tag_skiptest <- function (tag, test, ...) {
  test
}


add_lines_to_test <- function (tag, test) {
  example_lines <- strsplit(tag$raw, "\n", fixed = TRUE)[[1]]
  test$lines <- c(test$lines, example_lines)

  test
}


add_test_to_result <- function (test, result) {
  test <- process_expectations(test)
  result$tests <- c(result$tests, list(test))

  result
}

