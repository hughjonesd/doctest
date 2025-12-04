# Create an expectation

`@expect` creates an expectation for your example code.

## Details

Use `@expect` to create a
[testthat](https://testthat.r-lib.org/reference/testthat-package.html)
expectation.

    #' @doctest
    #'
    #' @expect equals(4)
    #' 2 + 2
    #'
    #' f <- function () warning("Watch out")
    #' @expect warning()
    #' f()

The next expression will be inserted as the first argument to the
`expect_*` call.

Don't include the `expect_` prefix.

If you want to include the expression in a different place or places,
use a dot `.`:

    @expect equals(., rev(.))
    c("T", "E", "N", "E", "T")

The `@expect` tag and code must fit on a single line.

## See also

Other expectations:
[`expectRaw-tag`](https://hughjonesd.github.io/doctest/reference/expectRaw-tag.md),
[`snap-tag`](https://hughjonesd.github.io/doctest/reference/snap-tag.md)
