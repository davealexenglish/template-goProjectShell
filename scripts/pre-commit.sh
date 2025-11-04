#!/bin/bash

# Pre-commit hook for Go projects
# This hook runs quality checks before allowing a commit

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running pre-commit checks...${NC}\n"

# Check if we're in a Go project
if [ ! -f "go.mod" ]; then
    echo -e "${RED}✗ No go.mod file found. Not a Go module?${NC}"
    exit 1
fi

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Track if any check fails
FAILED=0

# 1. Run go fmt
echo -e "${YELLOW}[1/6] Running go fmt...${NC}"
UNFORMATTED=$(gofmt -l .)
if [ -n "$UNFORMATTED" ]; then
    print_error "The following files are not formatted:"
    echo "$UNFORMATTED"
    echo ""
    echo "Run: make fmt"
    FAILED=1
else
    print_success "All files are properly formatted"
fi
echo ""

# 2. Run go vet
echo -e "${YELLOW}[2/6] Running go vet...${NC}"
if go vet ./...; then
    print_success "go vet passed"
else
    print_error "go vet found issues"
    FAILED=1
fi
echo ""

# 3. Run go mod tidy check
echo -e "${YELLOW}[3/6] Checking go.mod and go.sum...${NC}"
cp go.mod go.mod.bak
cp go.sum go.sum.bak
go mod tidy
if ! diff -u go.mod.bak go.mod || ! diff -u go.sum.bak go.sum; then
    print_error "go.mod or go.sum not tidy"
    echo "Run: make tidy"
    mv go.mod.bak go.mod
    mv go.sum.bak go.sum
    FAILED=1
else
    print_success "go.mod and go.sum are tidy"
    rm go.mod.bak go.sum.bak
fi
echo ""

# 4. Run staticcheck (if available)
echo -e "${YELLOW}[4/6] Running staticcheck...${NC}"
if command -v staticcheck &> /dev/null; then
    if staticcheck ./...; then
        print_success "staticcheck passed"
    else
        print_error "staticcheck found issues"
        FAILED=1
    fi
else
    echo -e "${YELLOW}⚠ staticcheck not installed (skipping)${NC}"
    echo "Install with: go install honnef.co/go/tools/cmd/staticcheck@latest"
fi
echo ""

# 5. Run golangci-lint (if available)
echo -e "${YELLOW}[5/6] Running golangci-lint...${NC}"
if command -v golangci-lint &> /dev/null; then
    if golangci-lint run ./...; then
        print_success "golangci-lint passed"
    else
        print_error "golangci-lint found issues"
        echo "Try: make lint-fix"
        FAILED=1
    fi
else
    echo -e "${YELLOW}⚠ golangci-lint not installed (skipping)${NC}"
    echo "Install from: https://golangci-lint.run/usage/install/"
fi
echo ""

# 6. Run tests with race detection
echo -e "${YELLOW}[6/6] Running tests with race detection...${NC}"
if go test -race -short ./...; then
    print_success "Tests passed"
else
    print_error "Tests failed"
    FAILED=1
fi
echo ""

# Final result
if [ $FAILED -eq 1 ]; then
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ Pre-commit checks FAILED${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo "Please fix the issues above before committing."
    echo "You can run individual checks using the Makefile:"
    echo "  make fmt       - Format code"
    echo "  make vet       - Run go vet"
    echo "  make tidy      - Tidy dependencies"
    echo "  make lint      - Run linters"
    echo "  make lint-fix  - Auto-fix linting issues"
    echo "  make test      - Run tests"
    echo ""
    echo "Or run all checks: make pre-commit"
    echo ""
    echo "To bypass this hook (not recommended): git commit --no-verify"
    exit 1
else
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ All pre-commit checks PASSED${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    echo ""
    exit 0
fi
