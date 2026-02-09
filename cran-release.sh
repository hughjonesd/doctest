#!/bin/bash
# CRAN Release Helper Script for doctest
# This script helps prepare and check the package for CRAN submission

set -e

PACKAGE_NAME="doctest"
VERSION="0.4.0"
TARBALL="${PACKAGE_NAME}_${VERSION}.tar.gz"

echo "=========================================="
echo "CRAN Release Helper for ${PACKAGE_NAME} ${VERSION}"
echo "=========================================="
echo ""

# Function to check if R is installed
check_r_installed() {
    if ! command -v R &> /dev/null; then
        echo "ERROR: R is not installed or not in PATH"
        exit 1
    fi
    echo "✓ R is installed: $(R --version | head -n1)"
}

# Function to check if required R packages are installed
check_r_packages() {
    echo ""
    echo "Checking required R packages..."
    
    Rscript -e "
    required_pkgs <- c('devtools', 'rcmdcheck', 'urlchecker')
    installed_pkgs <- installed.packages()[,'Package']
    missing_pkgs <- setdiff(required_pkgs, installed_pkgs)
    
    if (length(missing_pkgs) > 0) {
        cat('Missing packages:', paste(missing_pkgs, collapse=', '), '\n')
        cat('Install with: install.packages(c(\"', paste(missing_pkgs, collapse='\", \"'), '\"))\n', sep='')
        quit(status=1)
    } else {
        cat('✓ All required packages are installed\n')
    }
    "
}

# Function to check URLs in documentation
check_urls() {
    echo ""
    echo "Checking URLs in documentation..."
    Rscript -e "urlchecker::url_check()" || {
        echo "⚠ URL check completed with warnings (review above)"
    }
}

# Function to build the package
build_package() {
    echo ""
    echo "Building source package..."
    
    # Remove old tarball if exists
    if [ -f "$TARBALL" ]; then
        echo "Removing old tarball: $TARBALL"
        rm "$TARBALL"
    fi
    
    # Build the package
    R CMD build . --no-manual --no-build-vignettes || {
        echo "ERROR: Package build failed"
        exit 1
    }
    
    if [ -f "$TARBALL" ]; then
        echo "✓ Package built successfully: $TARBALL"
        echo "  Size: $(du -h $TARBALL | cut -f1)"
    else
        echo "ERROR: Tarball not created"
        exit 1
    fi
}

# Function to check the package with CRAN settings
check_package() {
    echo ""
    echo "Running R CMD check --as-cran..."
    
    if [ ! -f "$TARBALL" ]; then
        echo "ERROR: Tarball $TARBALL not found. Run build first."
        exit 1
    fi
    
    R CMD check --as-cran "$TARBALL" || {
        echo "ERROR: R CMD check failed"
        exit 1
    }
    
    echo "✓ R CMD check completed"
    
    # Show check results
    CHECK_DIR="${PACKAGE_NAME}.Rcheck"
    if [ -d "$CHECK_DIR" ]; then
        echo ""
        echo "Check results:"
        cat "${CHECK_DIR}/00check.log" | tail -20
    fi
}

# Function to run all checks
run_all_checks() {
    echo ""
    echo "Running all checks..."
    
    Rscript -e "
    cat('Running rcmdcheck...\n')
    results <- rcmdcheck::rcmdcheck(args = c('--no-manual', '--as-cran'))
    print(results)
    
    if (length(results\$errors) > 0 || length(results\$warnings) > 0) {
        cat('\n❌ Checks failed!\n')
        quit(status=1)
    } else {
        cat('\n✓ All checks passed!\n')
    }
    "
}

# Main menu
show_menu() {
    echo ""
    echo "Select an option:"
    echo "  1) Check R installation and packages"
    echo "  2) Check URLs in documentation"
    echo "  3) Build source package (.tar.gz)"
    echo "  4) Run R CMD check --as-cran on built package"
    echo "  5) Run all checks using rcmdcheck"
    echo "  6) Full workflow (build + check)"
    echo "  7) Exit"
    echo ""
    read -p "Enter choice [1-7]: " choice
    
    case $choice in
        1)
            check_r_installed
            check_r_packages
            show_menu
            ;;
        2)
            check_urls
            show_menu
            ;;
        3)
            build_package
            show_menu
            ;;
        4)
            check_package
            show_menu
            ;;
        5)
            run_all_checks
            show_menu
            ;;
        6)
            build_package
            check_package
            echo ""
            echo "✓ Full workflow completed!"
            echo "  Package ready for CRAN submission: $TARBALL"
            show_menu
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            show_menu
            ;;
    esac
}

# Check if running in interactive mode
if [ -t 0 ]; then
    # Interactive mode
    check_r_installed
    show_menu
else
    # Non-interactive mode - run full workflow
    check_r_installed
    build_package
    check_package
    echo ""
    echo "✓ Package is ready for CRAN submission: $TARBALL"
fi
