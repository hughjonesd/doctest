

#' Create the doctest roclet
#'
#' You can use this in your package DESCRIPTION like this:
#' ```r
#' Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::dt_roclet"))
#' ```
#'
#' @return The doctest roclet
#' @export
#' @examples
#' \dontrun{
#' roxygen2::roxygenize(roclets = "doctest::dt_roclet")
#' }
dt_roclet <- function () {
  roxygen2::roclet("doctest")
}


#' @export
roclet_process.roclet_doctest <- function (x, blocks, env, base_path) {
  results <- lapply(blocks, build_result_from_block)
  results <- purrr::compact(results)

  results
}


build_result_from_block <- function (block) {
  if (! roxygen2::block_has_tags(block, c("expect", "expectRaw", "doctest",
                                          "testComments"))) {
    return(NULL)
  }

  tags <- roxygen2::block_get_tags(block, c("expect", "expectRaw",
                                            "examples", "doctest",
                                            "testComments", "skipTest",
                                            "resumeTest"))

  result <- structure(list(tests = list()), class = "doctest_result")

  result$file <- basename(block$file)
  result$object <- block_name(block)
  result$test_comments <- roxygen2::block_has_tags(block, "testComments")

  test <- new_test(
                   name = sprintf("Example: %s", result$object),
                   source_object = result$object,
                   source_file = tags[[1]]$file,
                   source_line = tags[[1]]$line
                   )
  for (tag in tags) {
    if (inherits(tag, "roxy_tag_doctest")) {
      # create expectations
      result <- process_test(test, result)
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
  result <- process_test(test, result)

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
      "@doctest name must not include double quotes or backslashes",
      x = "Name was {.code {name}}"
    ))
  }

  if (source_file != "<text>") {
    source_file <- fs::path_rel(source_file, pkgload::pkg_path())
  }
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

add_tag_to_test.roxy_tag_expectRaw <- function (tag, test, ...) {
  # we put the expectation back, because we have to get rid of
  # \donttest etc.
  # we use .doctest_expect_ as a string to search for
  expect_line <- sprintf(".doctest_raw_expect_%s", tag$doctest_expect)
  test$lines <- c(test$lines, expect_line)
  test <- add_lines_to_test(tag, test)

  test
}



add_tag_to_test.roxy_tag_examples <- function (tag, test, ...) {
  add_lines_to_test(tag, test)
}


add_tag_to_test.roxy_tag_testComments <- add_tag_to_test.roxy_tag_examples


add_tag_to_test.roxy_tag_resumeTest <- add_tag_to_test.roxy_tag_examples


add_tag_to_test.roxy_tag_skipTest <- function (tag, test, ...) {
  test
}


add_lines_to_test <- function (tag, test) {
  if (length(tag$raw) == 0L) return(test)
  example_lines <- strsplit(tag$raw, "\n", fixed = TRUE)[[1]]
  test$lines <- c(test$lines, example_lines)

  test
}


process_test <- function (test, result) {
  test <- create_expectations(test, test_comments = result$test_comments)
  result$tests <- c(result$tests, list(test))

  result
}


