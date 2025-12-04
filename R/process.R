

#' @export
roclet_process.roclet_doctest <- function (x, blocks, env, base_path) {
  results <- lapply(blocks, build_result_from_block)
  results <- purrr::compact(results)

  results
}


build_result_from_block <- function (block) {
  if (! roxygen2::block_has_tags(block,
          c("doctest", "expect", "expectRaw", "snap"))) {
    return(NULL)
  }

  examples <- roxygen2::block_get_tags(block, c("examples", "example"))
  if (length(examples) > 0) {
    roxygen2::warn_roxy_tag(examples[[1]], c(
          "has {.code @examples} and {.code @doctest} sections in the same block",
          "i" = "Change {.code @examples} to {.code @doctest}",
          "i" = "Change {.code @example} to {.code @doctestExample}"
          ))
  }

  tags <- roxygen2::block_get_tags(block, c("doctest", "expect", "expectRaw",
                                           "testRaw", "snap", "omit", "resume",
                                           "doctestExample"))

  result <- structure(list(tests = list(), has_expectation = FALSE),
                      class = "doctest_result")

  result$file <- basename(block$file)
  result$object <- block_name(block)

  test <- NULL
  for (tag in tags) {
    if (inherits(tag, "roxy_tag_doctest")) {
      if (! is.null(test)) result <- process_test(test, result)
      test <- new_test(
                       name = test_name(tag, result),
                       source_object = result$object,
                       source_file = tag$file,
                       source_line = tag$line
                       )
    }

    if (! is.null(test)) {
      # we may add the @doctest tag to the test here
      test <- add_tag_to_test(tag, test)
    } else {
      roxygen2::warn_roxy_tag(tag, "cannot be used before a @doctest block")
    }
  }
  result <- process_test(test, result)

  result$lines <- test_file_contents(result)

  result
}


block_name <- function (block) {
  name_tag <- roxygen2::block_get_tag(block, "name")
  block$object$alias %||% name_tag$val %||% "unknown"
}


result_name <- function(result) {
  result$object %||% "unknown"
}


test_name <- function (tag, result) {
  # works with NULL and character(0):
  test_name <- paste(tag$doctest_test_name, collapse = "")
  if (test_name == "") {
    sprintf("Doctest: %s", result$object)
  } else {
    test_name
  }
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
                 name            = name,
                 source_object   = source_object,
                 source_file     = source_file,
                 source_line     = source_line,
                 lines           = character(0),
                 has_expectation = FALSE
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
  test$has_expectation <- TRUE

  test
}


add_tag_to_test.roxy_tag_snap <- add_tag_to_test.roxy_tag_expect


add_tag_to_test.roxy_tag_expectRaw <- function (tag, test, ...) {
  expect_line <- sprintf(".doctest_raw_expect_%s", tag$doctest_expect)
  test$lines <- c(test$lines, expect_line)
  test <- add_lines_to_test(tag, test)
  test$has_expectation <- TRUE

  test
}


add_tag_to_test.roxy_tag_testRaw <- function (tag, test, ...) {
  test$lines <- c(test$lines, tag$doctest_test_raw)
  test <- add_lines_to_test(tag, test)

  test
}


add_tag_to_test.roxy_tag_doctest <- function (tag, test, ...) {
  add_lines_to_test(tag, test)
}


add_tag_to_test.roxy_tag_doctestExample <- function (tag, test, ...) {
  test
}


add_tag_to_test.roxy_tag_omit <- function (tag, test, ...) {
  test
}


add_tag_to_test.roxy_tag_resume <- function (tag, test, ...) {
  add_lines_to_test(tag, test)
}


add_lines_to_test <- function (tag, test) {
  example_lines <- tag$val
  test$lines <- c(test$lines, example_lines)

  test
}


process_test <- function (test, result) {
  if (test$has_expectation) {
    rlang::try_fetch({
      test <- create_expectations(test)
      test <- top_and_tail(test)
      result$has_expectation <- TRUE
      result$tests <- c(result$tests, list(test))
    },
      error = function(e) {
        cli::cli_warn("Can't create test \"{test$name}\"",
          parent = e
        )
      }
    )
  }

  result
}


top_and_tail <- function (test) {
  test$lines <- paste0("  ", test$lines)
  test_opener <- c(
                   sprintf('test_that("%s", {', test$name),
                   sprintf("  # Created from @doctest for `%s`",
                           test$source_object),
                   sprintf("  # Source file: %s", test$source_file)
                  )

  test$lines <- c(test_opener, test$lines, "})", "")

  test
}


test_file_contents <- function (result) {
  test_file_name <- test_file_name(result)
  lines <- doctest_stamp()
  source_path <- file.path("R", result$file)
  lines <- c(lines, sprintf("# Please edit file in %s", source_path))

  lines <- c(lines, "")

  for (test in result$tests) {
    newlines <- test$lines
    lines <- c(lines, newlines)
  }

  lines
}


doctest_stamp <- function () {
  "# Generated by doctest: do not edit by hand"
}
