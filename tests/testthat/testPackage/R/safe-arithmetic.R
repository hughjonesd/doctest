#' Safe mean
#'
#' @param x Numeric vector
#'
#' @return Mean of `x`
#'
#' @export
#'
#' @doctest
#' x <- 1:3
#' @expect equal(2)
#' safe_mean(x)
#'
#' @doctest safe-mean-errors
#'
#' @expect warning("not numeric")
#' safe_mean("a")
#'
#' @expect warning("NA elements")
#' safe_mean(c(1, NA))
safe_mean <- function (x) {
  if (length(x) == 0L) stop("No elements in x")
  if (! is.numeric(x)) warning("x is not numeric")
  if (any(is.na(x))) warning("x contains NA elements")
  mean(x)
}


#' Safe variance
#'
#' @param x A number
#'
#' @return Variance of `x`
#' @export
#'
#' @doctest
#' x <- 1:5
#'
#' @expect length(1)
#' safe_var(x)
safe_var <- function (x) {
  if (length(x) == 0L) stop("No elements in x")
  if (! is.numeric(x)) stop("x is not numeric")
  if (any(is.na(x))) warning("x contains NA elements")
  stats::var(x)
}


#' Add two numbers
#'
#' @param x,y Numbers
#'
#' @return The sum of x and y
#' @export
#'
#' @doctest
#'
#' @expect equal(add(1, 1))
#' 1 + 1
#'
add <- function (x, y) {
  x + y
}


#' Add two numbers with an operator
#'
#' @param x,y Numbers
#'
#' @return The sum of x and y
#' @export
#'
#' @doctest
#' @expect equal(4)
#' 2 %plus% 2
`%plus%` <- function (x, y) {
  x+y
}
