# Create a snapshot test

`@snap` creates a [snapshot
test](https://testthat.r-lib.org/articles/snapshotting.html) for your
example. It is shorthand for `@expect snapshot()`.

## Details

Often, examples show complex output to the user. If this output changes,
you want to check that it still "looks right". Snapshot tests help by
failing when the output changes, and allowing you to review and approve
the new output.

    #' @doctest
    #'
    #' @snap
    #' summary(lm(Petal.Width ~ Species, data = iris))

## See also

Other expectations:
[`expect-tag`](https://hughjonesd.github.io/doctest/reference/expect-tag.md),
[`expectRaw-tag`](https://hughjonesd.github.io/doctest/reference/expectRaw-tag.md)
