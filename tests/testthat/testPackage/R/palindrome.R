


#' Return a palindrome
#'
#' @return A string
#' @export
#'
#' @doctest
#' p <- palindrome()
#' @expectRaw match(p, "Panama")
#' @omit
#' print(p)
#' @resume
#' pal_letters <- p |>
#'   tolower() |>
#'   (\(x) gsub("[^A-z]", "", x))() |>
#'   strsplit("") |>
#'   unlist()
#' @expectRaw equal(pal_letters, rev(pal_letters))
palindrome <- function () {
   "A man, a plan, a canal - Panama"
}


#' @export
#' @rdname palindrome
#' @doctest palindrome_letters
#' @testRaw skip_on_cran()
#' @expect equal(., rev(.))
#' tenet <- palindrome_letters()
palindrome_letters <- function () {
  c("t", "e", "n", "e", "t")
}
