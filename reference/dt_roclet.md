# Create the doctest roclet

You can use this in your package DESCRIPTION like this:

    Roxygen: list(roclets = c("collate", "rd", "namespace", "doctest::dt_roclet"))

## Usage

``` r
dt_roclet()
```

## Value

The doctest roclet

## Examples

``` r
if (FALSE) { # \dontrun{
roxygen2::roxygenize(roclets = "doctest::dt_roclet")
} # }
```
