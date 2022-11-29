

#' Create the doctest roclet
#'
#' You can use this in your package DESCRIPTION like this:
#' ```r
#' Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::dt_roclet"))
#' ```
#'
#' @return The doctest roclet
#' @export
#' @examples
#' \dontrun{
#' roxygen2::roxygenize(roclets = "doctest::dt_roclet")
#' }
dt_roclet <- function () {
  roxygen2::roclet("doctest")
}


#' Test doctests in a package
#'
#' This is a utility function to run doctests in a local source package.
#' It calls [testthat::test_local()].
#'
#' @param path Path to package
#' @param ... Passed to [testthat::test_local()].
#'
#' @return The result of [testthat::test_local()].
#' @export
#'
#' @examples
#' \dontrun{
#'   test_doctests()
#' }
test_doctests <- function (path = ".", ...) {
  testthat::test_local(path = path, filter = "doctest", ...)
}
