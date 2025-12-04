# Add an example from a file

`@doctestExample path/to/file.R` is a drop-in replacement for
`@example path/to/file.R`. It doesn't add the contents of `file.R` to
the test.

## Details

If you have complex examples you may want to store them separately.
Roxygen2 uses the `@example` tag for this. `@doctestExample` does the
same: it adds the contents of its file to the resulting example. Suppose
`man/R/example-code.R` contains the line:

    2 + 2

Then the following roxygen:

    #' @doctest
    #'
    #' @expect equal(2)
    #' 1 + 1
    #' @doctestExample man/R/example-code.R

will generate an example like:

    1 + 1
    2 + 2

At present, `@doctestExample` doesn't add any code to the tests.

`@doctestExample` was added in doctest 0.3.0.
