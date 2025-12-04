# Start a doctest

`@doctest` starts a doctest: a code example that also contains one or
more
[testthat](https://testthat.r-lib.org/reference/testthat-package.html)
expectations.

## Details

Use `@doctest` where you would usually use `@examples`. Then add
[@expect](https://hughjonesd.github.io/doctest/reference/expect-tag.md)
and
[@expectRaw](https://hughjonesd.github.io/doctest/reference/expectRaw-tag.md)
tags beneath it to create expectations.

By default, a test labelled "Example: \<object name\>" is created. You
can put a different label after `@doctest`:

    #' @doctest Positive numbers
    #'
    #' x <- 1
    #' @expect equal(x)
    #' abs(x)
    #'
    #' @doctest Negative numbers
    #' x <- -1
    #' @expect equal(-x)
    #' abs(x)

You can have more than one `@doctest` tag in a roxygen block. Each
doctest will create a new test, but they will all be merged into a
single Rd example. Each doctest must contain an independent unit of
code. For example, this won't work:

    #' @doctest Test x
    #' @expect equal(2)
    #' x <- 1 + 1
    #'
    #' @doctest Keep testing x
    #' @expect equal(4)
    #' x^2
    #' # Test will error, because `x` has not been defined here

A test will only be written if the `@doctest` section has at least one
[@expect](https://hughjonesd.github.io/doctest/reference/expect-tag.md)
or
[@expectRaw](https://hughjonesd.github.io/doctest/reference/expectRaw-tag.md)
in it. This lets you change `@examples` to `@doctest` in your code,
without generating unexpected tests.
