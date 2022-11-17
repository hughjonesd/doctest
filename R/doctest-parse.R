
#' @importFrom roxygen2 roxy_tag_parse
#' @importFrom roxygen2 roxy_tag_rd
NULL

#' @export
roxy_tag_parse.roxy_tag_expect <- function (x) {
  x <- strip_first_line(x, first_line_name = "expect")
  x$doctest_code <- clean_donts(x$raw)
  x <- roxygen2::tag_examples(x)

  x
}

#' @export
roxy_tag_parse.roxy_tag_test <- function (x) {
  x <- strip_first_line(x, first_line_name = "test_name")
  if (is.null(x$doctest_test_name)) {
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
  if (length(x$raw) > 0 && stringr::str_trim(x$raw) != "") {
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
    first_line_name <- paste0("doctest_", first_line_name)
    x[[first_line_name]] <- lines[[1]]
  }

  x
}


clean_donts <- function (text) {
  tf_in <- tempfile()
  tf_out <- tempfile()
  on.exit({
    file.remove(tf_in)
    file.remove(tf_out)
  })

  dummy_rd <- c("\\name{dummy}", "\\title{dummy}", "\\examples{", text, "}")
  cat(dummy_rd, file = tf_in, sep = "\n")
  # this comments out the actual \donttest but leaves the rest uncommented
  tools::Rd2ex(tf_in, tf_out, commentDontrun = FALSE, commentDonttest = FALSE)

  readLines(tf_out)
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

