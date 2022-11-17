#' Safe mean
#'
#' @param x Numeric vector
#'
#' @return Mean of `x`
#'
#' @export
#'
#' @examples
#' x <- 1:3
#' @expect equals(2)
#' safe_mean(x)
#'
#' @test safe-mean-errors
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


#' Safe variance
#'
#' @param x
#'
#' @return Variance of `x`
#' @export
#'
#' @examples
#' x <- 1:5
#' @expect length(1)
#' safe_var(x)
safe_var <- function (x) {
  if (length(x) == 0L) stop("No elements in x")
  if (! is.numeric(x)) stop("x is not numeric")
  if (any(is.na(x))) warning("x contains NA elements")
  var(x)
}


#' Add two numbers
#'
#' @param x,y Numbers
#'
#' @return The sum of x and y
#' @export
#'
#' @examples
#'
#' add(1, 2)
#'
#' @expect equals(add(1, 1))
#' 1 + 1
add <- function (x, y) {
  x + y
}
