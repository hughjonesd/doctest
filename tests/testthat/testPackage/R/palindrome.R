


#' Return a palindrome
#'
#' @return A string
#' @export
#'
#' @examples
#' 1 # to avoid warning
#' @doctest
#' @expect match(., "Panama")
#' palindrome()
#' @skipTest
#' print(p)
#' @resumeTest
#' pal_letters <- p |>
#'   tolower() |>
#'   gsub("[^A-z]", "", x = _) |>
#'   strsplit() |>
#'   unlist()
#' @expect equal(pal_letters, rev(pal_letters))
palindrome <- function () {
   "A man, a plan, a canal - Panama"
}
