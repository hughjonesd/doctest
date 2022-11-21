create_expectations <- function (test, test_comments) {
  example_lines <- clean_donts(test$lines)
  if (test_comments) {
    example_lines <- convert_comments_to_expectations(example_lines)
  }

  example_text <- paste(example_lines, collapse = "\n")
  example_exprs <- rlang::parse_exprs(example_text)

  example_exprs <- recursively_rewrite(example_exprs)

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


recursively_rewrite <- function(x) {
  switch(expr_type(x),
    symbol = {
      xs <- rlang::as_string(x)
      if (grepl("^\\.doctest_expect", xs)) {
        xs <- gsub("^\\.doctest_", "", xs)
        x <- rlang::sym(xs)
      }
      x
    },
    constant = x,
    pairlist = x, # pairlist can't be toplevel, can't be a ._doctest_expr call
    call = {
      purrr::modify(x, recursively_rewrite)
    },
    list = , # only at top level
    "{" = {
      x <- replace_dot(x)
      purrr::modify(x, recursively_rewrite)
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


replace_dot <- function(exprs) {
  for (ix in seq_along(exprs)) {
    expr <- exprs[[ix]]
    if (rlang::is_call_simple(expr) && grepl("^\\.doctest_expect",
                                             rlang::call_name(expr))) {
      has_dot <- purrr::map_lgl(expr, ast_has_dot)
      if (any(has_dot)) {
        if (ix < length(exprs)) {
          # replace dot with sibling
          exprs[[ix]] <- do.call("substitute",
                                 list(exprs[[ix]], list(. = exprs[[ix + 1]])))
          exprs <- exprs[-(ix+1)]
          return(exprs)
        } else {
          cli::cli_abort(
            "No expression to substitute for . in @expect",
            i = "A dot in an @expect tag is replaced by the next expression",
          )
        }
      }
    }
  }

  exprs
}


convert_comments_to_expectations <- function (lines) {
  parsed <- parse(text = lines, keep.source = TRUE)
  parse_data <- utils::getParseData(parsed)

  comments <- parse_data[parse_data$token == "COMMENT", ]
  comments <- comments[grepl("#\\s*expect\\s+", comments$text), ]

  comment_lines <- comments$line1
  expectations <- gsub("#\\s*expect\\s+(.+)", ".doctest_expect_\\1",
                       comments$text)

  other_stuff <- parse_data$line1 %in% comment_lines &
                 parse_data$token != "COMMENT"
  if (any(other_stuff)) {
    cli::cli_abort(c("Found code on same line as expectation comment",
                     i = "doctest comments must be on their own line"))
  }

  if (length(comment_lines) > 0L) {
    lines[comment_lines] <- expectations
  }

  lines
}


ast_has_dot <- function (x) {
  if (length(x) == 1) return(typeof(x) == "symbol" && as.character(x) == ".")
  if (length(x) > 1) any(unlist(lapply(x, ast_has_dot)))
}


clean_donts <- function (lines) {
  # also deals with character(0):
  if (paste(lines, collapse = "") == "") return(lines)
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
