


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
#'   (\(x) gsub("[^A-z]", "", x))() |>
#'   strsplit() |>
#'   unlist()
#' @expectRaw equal(pal_letters, rev(pal_letters))
palindrome <- function () {
   "A man, a plan, a canal - Panama"
}
