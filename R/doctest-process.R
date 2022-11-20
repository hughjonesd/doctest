

#' Create doctests from roxygen tags
#'
#' @return The doctest roclet
#' @export
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


process_expectations <- function (test) {
  example_lines <- clean_donts(test$lines)
  example_text <- paste(example_lines, collapse = "\n")
  example_exprs <- rlang::parse_exprs(example_text)

  is_expect <- function (expr) {
                 matches <- grepl("^\\.doctest_expect", as.character(expr))
                 matches[1]
               }
  expect_idx <- which(purrr::map_lgl(example_exprs, is_expect))
  target_idx <- expect_idx + 1

  expect_exprs <- example_exprs[expect_idx]
  target_exprs <- example_exprs[target_idx]

  expect_exprs <- purrr::map2(expect_exprs, target_exprs, make_expectation)
  example_exprs[expect_idx] <- expect_exprs
  example_exprs <- example_exprs[-target_idx]

  example_lines_list <- purrr::map(example_exprs, rlang::expr_deparse)
  test$lines <- purrr::flatten_chr(example_lines_list)

  test$lines <- paste0("  ", test$lines)
  test_opener <- c(
                   sprintf('test_that("%s", {', test$name),
                   sprintf("# Created from @examples for `%s`",
                           test$source_object),
                   sprintf("# Source file: '%s'", test$source_file),
                   sprintf("# Source line: %s", test$source_line)
                  )

  test$lines <- c(test_opener, test$lines, "})")

  test
}


make_expectation <- function (raw_expect_expr, target_expr) {
  if (! rlang::is_call_simple(raw_expect_expr)) {
    cli::cli_abort(c("@expect tag did not contain a call",
                     i = "An @expect tag must contain a call",
                     i = "Example: `@expect equals(0)`"))
  }
  expect_text <- rlang::call_name(raw_expect_expr)
  stopifnot(grepl("^\\.doctest_expect", expect_text))

  expect_text <- sub("^\\.doctest_", "", expect_text)
  expect_call <- rlang::sym(expect_text)
  expect_expr <- raw_expect_expr
  expect_expr[[1]] <- expect_call

  ast_has_a_dot <- function (x) {
    if (length(x) == 1) return(typeof(x) == "symbol" && as.character(x) == ".")
    if (length(x) > 1) any(unlist(lapply(x, ast_has_a_dot)))
  }
  has_dot <- ast_has_a_dot(expect_expr)

  expect_expr <- if (has_dot) {
                               do.call("substitute",
                                       list(expect_expr, list(. = target_expr)))
                              } else {
                                expect_args <- rlang::call_args(expect_expr)
                                expect_args <- c(target_expr, expect_args)
                                rlang::call2(expect_call, !!!expect_args)
                              }

  expect_expr
}


clean_donts <- function (lines) {
  if (length(lines) == 1 && lines == "") return(lines)
  tf_in <- tempfile("Rex")
  tf_out <- tempfile("Rex")
  on.exit({
    file.remove(tf_in)
    file.remove(tf_out)
  })

  dummy_rd <- c("\\name{dummy}", "\\title{dummy}", "\\examples{", lines, "}")
  cat(dummy_rd, file = tf_in, sep = "\n")
  # this comments out the actual \donttest but leaves the rest uncommented
  tools::Rd2ex(tf_in, tf_out, commentDontrun = FALSE, commentDonttest = FALSE)

  readLines(tf_out)
}
