
#' @importFrom roxygen2 roxy_tag_parse
#' @importFrom roxygen2 roxy_tag_rd
NULL

#' @export
roxy_tag_parse.roxy_tag_expect <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect")
  x <- roxygen2::tag_examples(x)

  x
}

#' @export
roxy_tag_parse.roxy_tag_test <- function (x) {
  x <- strip_first_line(x, first_line_name = "test_name")
  if (is.null(x$testygen_test_name)) {
    roxygen2::warn_roxy_tag(x, "requires a test name")
  }
  if (stringr::str_trim(x$raw) != "") {
    x <- roxygen2::tag_examples(x)
  }

  x
}


#' @export
roxy_tag_parse.roxy_tag_skiptest <- function (x) {
  x <- strip_first_line(x)
  x <- roxygen2::tag_examples(x)

  x
}


#' @export
roxy_tag_parse.roxy_tag_unskip <- function (x) {
  x <- strip_first_line(x)
  # we test so as not to warn if unskip is empty
  if (stringr::str_trim(x$raw) != "") {
    x <- roxygen2::tag_examples(x)
  }

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
    first_line_name <- paste0("testygen_", first_line_name)
    x[[first_line_name]] <- lines[[1]]
  }

  x
}


#' @export
roxy_tag_rd.roxy_tag_expect <- function(x, base_path, env) {
  rd_section("examples", x$val)
}


#' @export
roxy_tag_rd.roxy_tag_test <- roxy_tag_rd.roxy_tag_expect


#' @export
roxy_tag_rd.roxy_tag_skiptest <- roxy_tag_rd.roxy_tag_expect


#' @export
roxy_tag_rd.roxy_tag_unskip <- roxy_tag_rd.roxy_tag_expect

