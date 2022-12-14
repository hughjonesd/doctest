% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/docs.R
\name{omit-tag}
\alias{omit-tag}
\alias{resume-tag}
\alias{@omit}
\alias{@resume}
\title{Exclude example code from a test}
\description{
\verb{@omit} excludes example code from a test until the next tag.
Use \verb{@resume} to restart including code without creating an expectation.
}
\details{
Use \verb{@omit} to avoid redundant or noisy code:

\if{html}{\out{<div class="sourceCode">}}\preformatted{#' @doctest
#'
#' @expect equal(0)
#' sin(0)
#'
#' @omit
#' curve(sin(x), 0, 2 * pi)
#'
#' @expect equal(1)
#' cos(0)
}\if{html}{\out{</div>}}

\verb{@omit} is separate from \verb{\donttest} and \verb{\dontrun} tags in Rd files. This
allows you to test code that would cause an error if run by R CMD CHECK. If
you also want R CMD CHECK to skip your code, you should use \verb{\donttest{}}
separately (see
\href{https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-R-documentation-files}{writing R extensions}).

Remember that the main purpose of examples is to document your package for
your users. If your code is getting too different from your example, consider
splitting it off into a proper test file. You can do this by renaming it and
deleting the \verb{Generated by doctest} comment.
}
