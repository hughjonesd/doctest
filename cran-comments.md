Dear CRAN maintainers,

I am submitting version 0.4.0 of the doctest package.

### What's new in this version

This release improves the quality of generated tests by not producing "Source line" information, which avoids changes irrelevant to examples from modifying the tests.

### Testing

The package has been thoroughly tested on multiple platforms using GitHub Actions with r-lib/actions@v2:

- **macOS-latest** (R release)
- **Windows-latest** (R release)
- **Ubuntu-latest** (R devel)
- **Ubuntu-latest** (R release)
- **Ubuntu-latest** (R oldrel-1)

All checks pass with **0 errors, 0 warnings, and 0 notes**.

### Additional Information

- Package documentation: https://hughjonesd.github.io/doctest/
- Bug reports: https://github.com/hughjonesd/doctest/issues
- License: MIT + file LICENSE

Thank you for your time and consideration in reviewing this submission.

Best regards,

David Hugh-Jones
