
#' @importFrom roxygen2 roxy_tag_parse
#' @importFrom roxygen2 roxy_tag_rd
NULL

#' @export
roxy_tag_parse.roxy_tag_expect <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect")
  if (is.null(x$doctest_expect) || x$doctest_expect == "") {
    roxygen2::warn_roxy_tag(x, "has no expectation defined")
  }

  x <- tag_nonempty_examples(x)

  x
}

#' @export
roxy_tag_parse.roxy_tag_test <- function (x) {
  x <- strip_first_line(x, first_line_name = "test_name")
  if (is.null(x$doctest_test_name)) {
    roxygen2::warn_roxy_tag(x, "requires a test name")
  }

  x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_skiptest <- function (x) {
  x <- strip_first_line(x)
  x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_unskip <- function (x) {
  x <- strip_first_line(x)
  x <- tag_nonempty_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_testcomments <- function (x) {
  x <- strip_first_line(x)
  x <- tag_nonempty_examples(x)

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

tag_nonempty_examples <- function (x) {
  if (length(x$raw) > 0 && stringr::str_trim(x$raw) != "") {
    x <- roxygen2::tag_examples(x)
  }

  x
}


#' @export
roxy_tag_rd.roxy_tag_expect <- function(x, base_path, env) {
  roxygen2::rd_section("examples", x$val)
}


#' @export
roxy_tag_rd.roxy_tag_test <- roxy_tag_rd.roxy_tag_expect


#' @export
roxy_tag_rd.roxy_tag_skiptest <- roxy_tag_rd.roxy_tag_expect


#' @export
roxy_tag_rd.roxy_tag_unskip <- roxy_tag_rd.roxy_tag_expect


#' @export
roxy_tag_rd.roxy_tag_testcomments <- roxy_tag_rd.roxy_tag_expect
