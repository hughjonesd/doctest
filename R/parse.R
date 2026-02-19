
#' @importFrom roxygen2 roxy_tag_parse
#' @importFrom roxygen2 roxy_tag_rd
NULL


#' @export
roxy_tag_parse.roxy_tag_expect <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect")
  if (is.null(x$doctest_expect) || x$doctest_expect == "") {
    roxygen2::warn_roxy_tag(x, "has no expectation defined")
  }

  x
}


#' @export
roxy_tag_parse.roxy_tag_snap <- function (x) {
  x <- strip_first_line(x)
  x$doctest_expect <- "snapshot()"

  x
}


#' @export
roxy_tag_parse.roxy_tag_expectRaw <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect_raw")
  if (is.null(x$doctest_expect_raw) || x$doctest_expect_raw == "") {
    roxygen2::warn_roxy_tag(x, "has no expectation defined")
  }

  x
}


#' @export
roxy_tag_parse.roxy_tag_testRaw <- function (x) {
  x <- strip_first_line(x, first_line_name = "test_raw")
  if (is.null(x$doctest_test_raw) || x$doctest_test_raw == "") {
    roxygen2::warn_roxy_tag(x, c("has no content",
                                 i = "Add R code on the same line as @testRaw.")
                            )
  }

  x
}


#' @export
roxy_tag_parse.roxy_tag_doctest <- function (x) {
  x <- strip_first_line(x, first_line_name = "test_name")

  x
}


#' @export
roxy_tag_parse.roxy_tag_omit <- function (x) {
  x <- strip_first_line(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_resume <- function (x) {
  x <- strip_first_line(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_doctestExample <- function (x) {
  x <- roxygen2::tag_value(x)
}


strip_first_line <- function (x, first_line_name = NULL) {
  if (is.null(x$raw)) x$raw <- ""
  lines <- strsplit(x$raw, "\n", fixed = TRUE)[[1]]

  if (length(lines)) {
    x$val <- paste(lines[-1], collapse = "\n")
  } else {
    x$val <- character(0)
  }

  if (! is.null(first_line_name) && length(lines)) {
    first_line_name <- paste0("doctest_", first_line_name)
    x[[first_line_name]] <- lines[[1]]
  }

  x
}


#' @export
roxy_tag_rd.roxy_tag_doctest <- function(x, base_path, env) {
  sect <- roxygen2::rd_section("doctest", x$val)
  # we keep the tag around for error messages during Rd parsing
  #
  sect$tag <- x
  sect
}


#' @export
roxy_tag_rd.roxy_tag_doctestExample <- function (x, base_path, env) {
    path <- file.path(base_path, x$val)
    if (!file.exists(path)) {
        roxygen2::warn_roxy_tag(x, "{.path {path}} doesn't exist")
        return()
    }

    code <- readLines(path, encoding = "UTF-8", warn = FALSE)
    sect <- roxygen2::rd_section("doctest", code)
    x$value <- code
    sect$tag <- x

    sect
}


#' @export
roxy_tag_rd.roxy_tag_expect <- roxy_tag_rd.roxy_tag_doctest


#' @export
roxy_tag_rd.roxy_tag_snap <- roxy_tag_rd.roxy_tag_doctest


#' @export
roxy_tag_rd.roxy_tag_expectRaw <- roxy_tag_rd.roxy_tag_doctest


#' @export
roxy_tag_rd.roxy_tag_testRaw <- function (x, base_path, env) {
  NULL
}


#' @export
roxy_tag_rd.roxy_tag_omit <- roxy_tag_rd.roxy_tag_doctest


#' @export
roxy_tag_rd.roxy_tag_resume <- roxy_tag_rd.roxy_tag_doctest


#' @export
merge.rd_section_doctest <- function (x, y, ...) {
  x_tag <- x$tag
  x <- NextMethod()
  x$tag <- x_tag
  x
}


#' @export
format.rd_section_doctest <- function (x, ...) {
  # x$value is a vector of lines which have not yet been parsed
  # we need to call tag_examples

  tag <- x$tag
  tag$raw <- paste(x$value, collapse = "\n")
  tag <- roxygen2::tag_examples(tag)
  # now tag$val contains parsed Rd. Maybe!
  if (is.null(tag)) {
    return("")
  } else {
    # OK, we can now be an examples section.
    # directly copied from rd_macro:
    values <- paste0("\n", paste0(tag$val, collapse = "\n"), "\n")
    rd <- paste0("\\examples", paste0("{", values, "}", collapse = ""))
    return(rd)
  }
}
