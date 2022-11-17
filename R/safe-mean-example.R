#' Safe mean
#'
#' @param x Numeric vector
#'
#' @examples
#'
#' @expect equals(2)
#' safe_mean(1:3)
#'
#' @expect error("not numeric")
#' safe_mean("a")
#'
#' @expect warning("NA elements")
#' safe_mean(c(1, NA))
safe_mean <- function (x) {
  if (length(x) == 0L) stop("No elements in x")
  if (! is.numeric(x)) stop("x is not numeric")
  if (any(is.na(x))) warning("x contains NA elements")
  mean(x)
}
