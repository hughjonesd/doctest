

#' @export
doctest_roclet <- function () {
  roxygen2::roclet("doctest")
}

#' @importFrom roxygen2 roclet_process
#' @export
roclet_process.roclet_doctest <- function (x, blocks, env, base_path) {
  results <- lapply(blocks, build_result_from_block)

  return(results)
}


build_result_from_block <- function (block) {
  if (! roxygen2::block_has_tags(block, c("expect", "test"))) return(list())

  tags <- roxygen2::block_get_tags(block, c("expect", "examples", "test"))

  result <- structure(list(tests = list()), class = "testygen_result")

  result$file <- basename(block$file)
  result$object <- block$object$alias

  test <- new_test(
                   name = sprintf("Example: %s", block$object$alias),
                   source_object = block$object$alias,
                   source_file = tags[[1]]$file,
                   source_line = tags[[1]]$line
                   )
  for (tag in tags) {
    if (inherits(tag, "roxy_tag_test")) {
      result$tests <- c(result$tests, list(test))
      test <- new_test(
                       name = tag$testygen_test_name,
                       source_object = block$object$alias,
                       source_file = tag$file,
                       source_line = tag$line
                       )
      next
    }
    test <- add_tag_to_test(tag, test)
  }
  result$tests <- c(result$tests, list(test))

  result$tests <- Filter(\(x) x$has_expectation, result$tests)

  result
}


new_test <- function (name, source_object, source_file, source_line) {
    structure(list(
                   name   = name,
                   source_object = source_object,
                   source_file   = source_file,
                   source_line   = source_line,
                   has_expectation = FALSE
                  ),
              class = "testygen_test")
}


add_tag_to_test <- function (x, test) UseMethod("add_tag_to_test", x)


add_tag_to_test.roxy_tag_expect <- function (x, test, ...) {
  lines <- strsplit(x$raw, "\n", fixed = TRUE)[[1]]
  lines_expression <- parse(text = lines)

  expectation <- x$testygen_expect
  expectation <- trimws(expectation)
  expectation <- paste0("expect_", expectation)
  expectation <- parse(text = expectation, n = 1)[[1]]

  target <- lines_expression[[1]]
  expectation <- as.call(c(expectation[[1]],
                           target, as.list(expectation[-1])))
  expectation <- deparse(expectation)

  rest <- if (length(lines_expression) > 1) {
            deparse(lines_expression[-1])
          } else {
            character(0)
          }

  lines <- c(expectation, rest)

  test$lines <- c(test$lines, lines)
  test$has_expectation <- TRUE

  test
}


add_tag_to_test.roxy_tag_examples <- function (x, test, ...) {
  example_lines <- strsplit(x$raw, "\n", fixed = TRUE)[[1]]
  test$lines <- c(test$lines, example_lines)

  test
}


add_tag_to_test.roxy_tag_unskip <- add_tag_to_test.roxy_tag_examples


add_tag_to_test.roxy_tag_skiptest <- function (x, test, ...) {
  test
}
