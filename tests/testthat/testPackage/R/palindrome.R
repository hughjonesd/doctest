


#' Return a palindrome
#'
#' @return A string
#' @export
#'
#' @examples
#' p <- palindrome()
#' @expect match("Panama")
#' @skiptest
#' print(p)
#' @unskip
#' @expect equal(., rev(.))
#' p |>
#'   tolower() |>
#'   gsub("[^A-z]", "", x = _) |>
#'   strsplit() |>
#'   unlist()
palindrome <- function () {
   "A man, a plan, a canal - Panama"
}
