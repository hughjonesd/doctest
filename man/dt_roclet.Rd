% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{dt_roclet}
\alias{dt_roclet}
\title{Create the doctest roclet}
\usage{
dt_roclet()
}
\value{
The doctest roclet
}
\description{
You can use this in your package DESCRIPTION like this:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::dt_roclet"))
}\if{html}{\out{</div>}}
}
\examples{
\dontrun{
roxygen2::roxygenize(roclets = "doctest::dt_roclet")
}
}
