process_expectations <- function (test) {
  example_lines <- clean_donts(test$lines)
  example_text <- paste(example_lines, collapse = "\n")
  example_exprs <- rlang::parse_exprs(example_text)

  is_expect <- function (expr) {
                 matches <- grepl("^\\.doctest_expect", as.character(expr))
                 matches[1]
  }
  expect_lgl <- purrr::map_lgl(example_exprs, is_expect)
  expect_idx <- which(expect_lgl)
  target_idx <- expect_idx + 1

  expect_with_dot_lgl <- expect_lgl & purrr::map_lgl(example_exprs, ast_has_dot)
  expect_with_dot_idx <- which(expect_with_dot_lgl)
  target_with_dot_idx <- expect_with_dot_idx + 1

  expect_exprs <- example_exprs[expect_idx]
  target_exprs <- example_exprs[target_idx]

  expect_exprs <- purrr::map2(expect_exprs, target_exprs, make_expectation)
  example_exprs[expect_idx] <- expect_exprs
  # if target was used in expectation, we remove it from the test code
  # the `if` is needed because x[-numeric(0)] == x[numeric(0)] == numeric(0)
  if (length(target_with_dot_idx)) {
    example_exprs <- example_exprs[-target_with_dot_idx]
  }
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

  has_dot <- ast_has_dot(expect_expr)

  if (has_dot) {
    expect_expr <- do.call("substitute",
                           list(expect_expr, list(. = target_expr)))
  }

  expect_expr
}


ast_has_dot <- function (x) {
  if (length(x) == 1) return(typeof(x) == "symbol" && as.character(x) == ".")
  if (length(x) > 1) any(unlist(lapply(x, ast_has_dot)))
}


clean_donts <- function (lines) {
  if (length(lines) == 1 && lines == "") return(lines)
  tf_in <- tempfile("Rex")
  tf_out <- tempfile("Rex")
  on.exit({
    file.remove(tf_in)
    file.remove(tf_out)
  })

  # We need to do this to e.g. convert %plus% to \%plus\% ...
  # otherwise tools::Rd2ex() will do bad things
  # add in starting roxygen tags
  dummy_rox <- paste0("#' ", lines, collapse = "\n")
  # calls escape_examples() but uses an exported function
  dummy_rox <- roxygen2::tag_examples(list(raw = dummy_rox))
  dummy_rd <- as.character(dummy_rox$val)
  # get rid of starting roxygen tags.
  dummy_rd <- gsub("(^|\n)#'", "\n", dummy_rd)

  dummy_rd <- c("\\name{dummy}", "\\title{dummy}", "\\examples{", dummy_rd, "}")
  cat(dummy_rd, file = tf_in, sep = "\n")

  # this comments out the actual \donttest but leaves the rest uncommented
  tools::Rd2ex(tf_in, tf_out, commentDontrun = FALSE, commentDonttest = FALSE)

  readLines(tf_out)
}
