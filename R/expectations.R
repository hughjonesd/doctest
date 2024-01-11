create_expectations <- function (test) {
  example_lines <- test$lines
  if (any(grepl("donttest|dontrun|dontshow", example_lines))) {
    example_lines <- clean_donts(example_lines, test = test)
  }

  example_text <- paste(example_lines, collapse = "\n")
  example_exprs <- rlang::try_fetch(
    rlang::parse_exprs(example_text),
    error = function (e) {
      cli::cli_abort("Failed to parse code in doctest for {test$source_object}.",
        parent = e
      )
    }
  )

  example_exprs <- recursively_rewrite(example_exprs)

  example_lines_list <- purrr::map(as.list(example_exprs), rlang::expr_deparse)
  test$lines <- purrr::flatten_chr(example_lines_list)

  test
}


recursively_rewrite <- function(x) {
  switch(expr_type(x),
    symbol = {
      xs <- rlang::as_string(x)
      if (grepl("^\\.doctest_(raw_)?expect", xs)) {
        xs <- gsub("^\\.doctest_(raw_)?", "", xs)
        x <- rlang::sym(xs)
      }
      x
    },
    constant = x,
    pairlist = x, # pairlist can't be toplevel, can't be a ._doctest_expr call
    call = {
      as.call(purrr::modify(as.list(x), recursively_rewrite))
    },
    list = , # only at top level
    "{" = {
      x <- rewrite_expectation_list(x)
      as.call(purrr::modify(as.list(x), recursively_rewrite))
    }
  )
}



expr_type <- function(x) {
  if (rlang::is_syntactic_literal(x)) {
    "constant"
  } else if (is.symbol(x)) {
    "symbol"
  } else if (is.call(x)) {
     if (inherits(x, "{")) "{" else "call"
  } else if (is.pairlist(x)) {
    "pairlist"
  } else {
    typeof(x)
  }
}


rewrite_expectation_list <- function(exprs) {
  for (ix in seq_along(exprs)) {
    expr <- exprs[[ix]]
    if (rlang::is_call_simple(expr) && grepl("^\\.doctest_expect",
                                             rlang::call_name(expr))) {
      if (ix < length(exprs)) {
        exprs[[ix]] <- rewrite_expectation(exprs[[ix]], exprs[[ix+1]])
        exprs <- exprs[-(ix+1)]
        # we've now shortened `exprs`, so we can't just keep going through
        # the loop.
        # We call rewrite_expectation_list() with any remainder
        # e.g. if ix+1 was 5 we now have 1,2,3,4, 5 (was 6), 6 (was 7)
        if (length(exprs) > ix + 1) {
          remaining <- seq(ix + 1, length(exprs))
          remaining_exprs <- rewrite_expectation_list(exprs[remaining])
          exprs <- c(exprs[seq(1, ix)], remaining_exprs)
        }
        return(exprs)
      } else {
        cli::cli_abort(c(
          "No expression after {.code @expect}",
          i = "An {.code @expect} tag refers to the expression after it",
          i = "Did you mean {.code @expectRaw}?"
        ))
      }
    }
  }

  exprs
}


rewrite_expectation <- function (expect_expr, target_expr) {
  has_dot <- purrr::map_lgl(as.list(expect_expr), ast_has_dot)
  if (any(has_dot)) {
    # replace dot with sibling
    expect_expr <- do.call("substitute",
                           list(expect_expr, list(. = target_expr)))

  } else {
    # it's fine for .ns to be NULL
    expect_expr <- rlang::call2(rlang::call_name(expect_expr),
                                target_expr,
                                !!! rlang::call_args(expect_expr),
                                .ns = rlang::call_ns(expect_expr))
  }

  expect_expr
}


ast_has_dot <- function (x) {
  if (length(x) == 1) return(typeof(x) == "symbol" && as.character(x) == ".")
  if (length(x) > 1) any(unlist(lapply(x, ast_has_dot)))
}


clean_donts <- function (lines, test) {
  # also deals with character(0):
  if (paste(lines, collapse = "") == "") return(lines)
  tf_in <- tempfile("Rex")
  tf_out <- tempfile("Rex")
  on.exit(suppressWarnings({
    file.remove(tf_in)
    file.remove(tf_out)
  }))

  # We need to do this to e.g. convert %plus% to \%plus\% ...
  # otherwise tools::Rd2ex() will do bad things
  # add in starting roxygen tags
  dummy_rox <- paste0(lines, collapse = "\n")
  # calls escape_examples() but uses an exported function
  dummy_rox <- roxygen2::tag_examples(roxygen2::roxy_tag("doctest",
                                               raw = dummy_rox,
                                               file = test$source_file,
                                               line = test$source_line))
  dummy_rd <- as.character(dummy_rox$val)

  dummy_rd <- c("\\name{dummy}", "\\title{dummy}", "\\examples{", dummy_rd, "}")
  cat(dummy_rd, file = tf_in, sep = "\n")

  # this comments out the actual \donttest but leaves the rest uncommented
  tools::Rd2ex(tf_in, tf_out, commentDontrun = FALSE, commentDonttest = FALSE)

  rlang::try_fetch(
    suppressWarnings(readLines(tf_out)), # typically throws warning AND error
    error = function (e) {
      cli::cli_abort("tools::Rd2ex failed to clean test \"{test$name}\"", parent = e)
    }
  )
}
