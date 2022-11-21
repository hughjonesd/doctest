
#' @importFrom roxygen2 roxy_tag_parse
#' @importFrom roxygen2 roxy_tag_rd
NULL

#' @export
roxy_tag_parse.roxy_tag_expect <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect")
  if (is.null(x$doctest_expect) || x$doctest_expect == "") {
    roxygen2::warn_roxy_tag(x, "has no expectation defined")
  }

  # x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_expectRaw <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect_raw")
  if (is.null(x$doctest_expect_raw) || x$doctest_expect_raw == "") {
    roxygen2::warn_roxy_tag(x, "has no expectation defined")
  }

  x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_doctest <- function (x) {
  x <- strip_first_line(x, first_line_name = "test_name")

  # x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_skipTest <- function (x) {
  x <- strip_first_line(x)
  # x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_resumeTest <- function (x) {
  x <- strip_first_line(x)
  # x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_testComments <- function (x) {
  x <- strip_first_line(x)
  # x <- tag_nonempty_examples(x)

  x
}


strip_first_line <- function (x, first_line_name = NULL) {
  if (is.null(x$raw)) return(x)
  lines <- strsplit(x$raw, "\n", fixed = TRUE)[[1]]

  if (length(lines)) {
    x$raw <- paste(lines[-1], collapse = "\n")
  } else {
    x$raw <- character(0)
  }

  if (! is.null(first_line_name) && length(lines)) {
    first_line_name <- paste0("doctest_", first_line_name)
    x[[first_line_name]] <- lines[[1]]
  }

  x
}


#' @export
roxy_tag_rd.roxy_tag_doctest <- function(x, base_path, env) {
  x <- roxygen2::rd_section("doctest", x$raw)
  x$is_doctest_tag <- TRUE

  x
}


#' @export
roxy_tag_rd.roxy_tag_expect <- function(x, base_path, env) {
  x <- roxygen2::rd_section("doctest", x$raw)
  x$is_doctest_tag <- FALSE

  x
}


#' @export
roxy_tag_rd.roxy_tag_expectRaw <- roxy_tag_rd.roxy_tag_expect


#' @export
roxy_tag_rd.roxy_tag_skipTest <- function(x, base_path, env) {
  x <- roxygen2::rd_section("doctest", x$raw)
  x$is_doctest_tag <- FALSE

  x
}



#' @export
roxy_tag_rd.roxy_tag_resumeTest <- function(x, base_path, env) {
  x <- roxygen2::rd_section("doctest", x$raw)
  x$is_doctest_tag <- FALSE

  x
}


#' @export
roxy_tag_rd.roxy_tag_testComments <- function(x, base_path, env) {
  x <- roxygen2::rd_section("doctest", x$raw)
  x$is_doctest_tag <- FALSE

  x
}


#' @export
merge.rd_section_doctest <- function (x, y, ...) {
  x_is_doctest_tag <- x$is_doctest_tag
  x <- NextMethod()
  x$is_doctest_tag <- x_is_doctest_tag

  if (! is.null(x$is_doctest_tag) && x$is_doctest_tag) {
    # try to recreate ourselves, but with parsed Rd
    raw <- paste(x$value, collapse = "\n")
    if (raw != "") {
      tmp_tag <- roxy_tag("roxy_tag_doctest", raw = raw)
      tmp_tag <- roxygen2::tag_examples(tmp_tag)
      if (! is.null(tmp_tag)) {
        x$value <- tmp_tag$val
      }
    }
  } else if (is.null(x$is_doctest_tag)) {
    recover()
  }

  x
}

#' @export
format.rd_section_doctest <- function (x, ...) {
  value <- paste0(x$value, collapse = "\n")
  roxygen2:::rd_macro("examples", value, space = TRUE)
}

# THE PROBLEM
# ===========
# - if roxy_tag_rd returns an rd_section("examples"),
#   - then it gets merged nicely with the real @examples section...
#   - BUT any tags that aren't at top level cause a "mismatched braces"
#     error or similar, and we get no example section in the Rd
# - if roxy_tag_rd returns its own kind of rd_section(),
#   - then we can merge all the sections nicely with each other...
#   - BUT they dont' get merged with the real examples section
#
# One radical solution is to *replace* the @examples tag with a doctest
# tag. This then does all the work. It might seem a bit scary to people?
# But it would allow for use of ordinary tags in the middle of the prose
# and we'd cut down on the crap...!
