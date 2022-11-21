


#' Return a palindrome
#'
#' @return A string
#' @export
#'
#' @doctest
#' p <- palindrome()
#' @expectRaw match(p, "Panama")
#' @skipTest
#' print(p)
#' @resumeTest
#' pal_letters <- p |>
#'   tolower() |>
#'   gsub("[^A-z]", "", x = _) |>
#'   strsplit() |>
#'   unlist()
#' @expectRaw equal(pal_letters, rev(pal_letters))
palindrome <- function () {
   "A man, a plan, a canal - Panama"
}
