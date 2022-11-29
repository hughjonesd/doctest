

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
