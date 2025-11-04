#!/bin/bash

# Setup script for new developers
# This script sets up the development environment

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ProjectShell Development Setup                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info
print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if Go is installed
echo -e "${YELLOW}[1/7] Checking Go installation...${NC}"
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    print_success "Go is installed: $GO_VERSION"
else
    print_error "Go is not installed"
    echo "Please install Go from: https://golang.org/dl/"
    exit 1
fi
echo ""

# Check if Make is installed
echo -e "${YELLOW}[2/7] Checking Make installation...${NC}"
if command -v make &> /dev/null; then
    print_success "Make is installed"
else
    print_error "Make is not installed"
    echo "Please install Make:"
    echo "  - macOS: xcode-select --install"
    echo "  - Linux: sudo apt-get install build-essential (Debian/Ubuntu)"
    echo "  - Windows: Use chocolatey or WSL"
    exit 1
fi
echo ""

# Download dependencies
echo -e "${YELLOW}[3/7] Downloading Go dependencies...${NC}"
if go mod download; then
    print_success "Dependencies downloaded"
else
    print_error "Failed to download dependencies"
    exit 1
fi
echo ""

# Verify dependencies
echo -e "${YELLOW}[4/7] Verifying dependencies...${NC}"
if go mod verify; then
    print_success "Dependencies verified"
else
    print_error "Dependency verification failed"
    exit 1
fi
echo ""

# Install development tools
echo -e "${YELLOW}[5/7] Installing development tools...${NC}"
print_info "This may take a few minutes..."

# Install staticcheck
if command -v staticcheck &> /dev/null; then
    print_success "staticcheck already installed"
else
    print_info "Installing staticcheck..."
    if go install honnef.co/go/tools/cmd/staticcheck@latest; then
        print_success "staticcheck installed"
    else
        print_error "Failed to install staticcheck"
    fi
fi

# Install golangci-lint
if command -v golangci-lint &> /dev/null; then
    print_success "golangci-lint already installed"
else
    print_info "Installing golangci-lint..."
    echo "Visit https://golangci-lint.run/usage/install/ for installation instructions"
    print_info "Or run: make install-tools"
fi
echo ""

# Install git hooks
echo -e "${YELLOW}[6/7] Installing git hooks...${NC}"
if [ -d ".git" ]; then
    mkdir -p .git/hooks
    if [ -f "scripts/pre-commit.sh" ]; then
        cp -f scripts/pre-commit.sh .git/hooks/pre-commit
        chmod +x .git/hooks/pre-commit
        print_success "Git pre-commit hook installed"
    else
        print_error "scripts/pre-commit.sh not found"
    fi
else
    print_info "Not a git repository, skipping hooks installation"
fi
echo ""

# Run initial checks
echo -e "${YELLOW}[7/7] Running initial checks...${NC}"
print_info "Formatting code..."
if go fmt ./... > /dev/null 2>&1; then
    print_success "Code formatted"
fi

print_info "Running go vet..."
if go vet ./... > /dev/null 2>&1; then
    print_success "go vet passed"
fi

print_info "Running tests..."
if go test -short ./... > /dev/null 2>&1; then
    print_success "Tests passed"
else
    print_info "Some tests failed (this might be expected)"
fi
echo ""

# Display next steps
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Setup Complete!                                 ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "  1. View all available commands:"
echo "     ${YELLOW}make help${NC}"
echo ""
echo "  2. Run the application:"
echo "     ${YELLOW}make run${NC}"
echo ""
echo "  3. Run all quality checks:"
echo "     ${YELLOW}make audit${NC}"
echo ""
echo "  4. Read the development guide:"
echo "     ${YELLOW}cat DEVELOPMENT.md${NC}"
echo "     or open in your browser"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  ${YELLOW}make test${NC}        - Run tests"
echo "  ${YELLOW}make test-race${NC}   - Run tests with race detection"
echo "  ${YELLOW}make lint${NC}        - Run linters"
echo "  ${YELLOW}make build${NC}       - Build binary"
echo "  ${YELLOW}make clean${NC}       - Clean build artifacts"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
