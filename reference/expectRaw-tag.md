# Create an expectation as-is

`@expectRaw` creates an expectation for your example code, without
adding the next expression as the subject.

## Details

`@expectRaw` creates a
[testthat](https://testthat.r-lib.org/reference/testthat-package.html)
expectation. Unlike
[@expect](https://hughjonesd.github.io/doctest/reference/expect-tag.md),
it doesn't insert the subsequent expression as the first argument.

    #' @doctest
    #'
    #' x <- 2 + 2
    #' @expectRaw equals(x, 4)
    #'
    #' f <- function () warning("Watch out")
    #' @expectRaw warning(f())

Don't include the `expect_` prefix.

The `@expectRaw` tag and code must fit on a single line.

## See also

Other expectations:
[`expect-tag`](https://hughjonesd.github.io/doctest/reference/expect-tag.md),
[`snap-tag`](https://hughjonesd.github.io/doctest/reference/snap-tag.md)
