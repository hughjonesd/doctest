
<!-- README.md is generated from README.Rmd. Please edit that file -->

# testygen

<!-- badges: start -->
<!-- badges: end -->

Testygen helps you to add “doctests” - tests combined with
documentation - to your R package. You do this by adding tags to your
roxygen examples.

## Installation

You can install the development version of testygen like so:

``` r
devtools::install("hughjonesd/testygen")
```

## Example

Here’s some documentation for a function:

``` r

#' Safe mean
#' 
#' @param x Numeric vector
#' @export
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
```

This will create tests like:

To use testygen, add the following line to your package DESCRIPTION:

    Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest")) 
