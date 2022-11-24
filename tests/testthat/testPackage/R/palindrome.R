


#' Return a palindrome
#'
#' @return A string
#' @export
#'
#' @doctest
#' p <- palindrome()
#' @expectRaw match(p, "Panama")
#' @pause
#' print(p)
#' @resume
#' pal_letters <- p |>
#'   tolower() |>
#'   (\(x) gsub("[^A-z]", "", x))() |>
#'   strsplit() |>
#'   unlist()
#' @expectRaw equal(pal_letters, rev(pal_letters))
palindrome <- function () {
   "A man, a plan, a canal - Panama"
}
