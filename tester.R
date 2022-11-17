library(testygen)
library(roxygen2)

text <- "
#' Test
#'
#' @param x
#'
#' @return `as.numeric(x)`
#' @export
#'
#' @examples
#' foo(1)
#'
#' @expect equal(2)
#' foo(2)
#'
#' @test test-abc
#' @expect warning()
#' foo(\"abc\")
#' @skiptest
#' print(\"This should give a warning\")
#'
#' @unskip
#'
#' @expect equal(NA)
#' foo(\"abc\")
foo <- function(x) as.numeric(x)
"

parse_text(text)
roc_proc_text(rd_roclet(), text)
results <- roc_proc_text(test_builder_roclet(), text)
roclet_output(test_builder_roclet(), results)
