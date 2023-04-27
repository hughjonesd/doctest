
Resubmitting following a manual check.

CRAN staff wrote:

> You have examples for unexported functions. Please either omit these examples or    export these functions.
  Examples for unexported function
    @omit() in:
        palindrome.Rd
    @resume() in:
        safe_mean.Rd
    snap-tag() in:
        safe_var.Rd

Those aren't functions, they are roxygen-style (https://roxygen2.r-lib.org/) tags which the user can add to documentation. No R object corresponds to them. It's nice to document them so the user can quickly find out what a tag does. The roxygen2 package does the same thing, see e.g. `?roxygen2::@title`.

The .Rd files referenced are in tests/testthat/testPackage. They are used for testing the roxygen2 tags, and are never visible to the user.

I emailed back, but haven't received a response, so I'm resubmitting.
If there's something else I should do, please say. Thanks as ever,

David


## R CMD check results

Platforms

* Mac (local): R 4.3.0
* Mac (mac-builder): r-release
* Windows (win-builder): r-devel and r-release
* Mac, Windows, Linux (github actions): r-devel, r-release, r-oldrel

One note about moved URLS. Fixed.


