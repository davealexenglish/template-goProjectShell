# Go Development Workflow - Complete Guide

This document provides a comprehensive overview of the professional Go development workflow implemented in this project.

## Overview

This project template includes everything you need for professional Go development:

- Automated formatting and linting
- Comprehensive testing with race detection
- Pre-commit hooks for code quality
- CI/CD pipeline with GitHub Actions
- Cross-platform building
- Coverage reporting
- Security scanning

## Daily Development Workflow

### 1. Starting Work

```bash
# Pull latest changes
git pull origin main

# Create a feature branch
git checkout -b feature/my-feature

# Ensure dependencies are up to date
make deps
```

### 2. Writing Code

As you write code, regularly run:

```bash
# Format your code (run frequently!)
make fmt

# Run tests quickly
make test-short

# Or run specific tests
go test -v ./pkg/user -run TestSpecificFunction
```

### 3. Before Committing

Run comprehensive checks:

```bash
# Option 1: Run all checks at once
make audit

# Option 2: Run checks individually
make fmt          # Format code
make vet          # Check for issues
make lint         # Run linters
make test-race    # Test with race detection

# Fix lint issues automatically
make lint-fix
```

### 4. Committing Changes

```bash
git add .
git commit -m "feat: add new feature"

# Pre-commit hooks automatically run:
# - go fmt check
# - go vet
# - go mod tidy check
# - staticcheck (if installed)
# - golangci-lint (if installed)
# - tests with race detection
```

**If hooks fail:**
- Review the error messages
- Fix the issues
- Run individual checks: `make fmt`, `make lint-fix`, etc.
- Try committing again

**Bypass hooks** (not recommended):
```bash
git commit --no-verify -m "message"
```

### 5. Pushing Changes

```bash
git push origin feature/my-feature
```

GitHub Actions will automatically:
- Run tests on Linux, macOS, and Windows
- Run linters
- Check formatting
- Check module tidiness
- Run security scans
- Build binaries for multiple platforms

## Essential Make Commands

### Development

```bash
make run              # Run the application
make build            # Build binary for current platform
make build-all        # Build for Linux, macOS, Windows
make install          # Install to $GOPATH/bin
make clean            # Clean build artifacts
```

### Code Quality

```bash
make fmt              # Format all code
make vet              # Run go vet
make lint             # Run all linters
make lint-fix         # Auto-fix linting issues
make staticcheck      # Run staticcheck
make tidy             # Tidy go.mod and go.sum
```

### Testing

```bash
make test             # Run all tests
make test-race        # Run with race detection (important!)
make test-cover       # Generate HTML coverage report
make test-short       # Run only fast tests
make test-bench       # Run benchmarks
```

### Combined Commands

```bash
make audit            # Run all quality checks
make ci               # Run CI checks locally
make pre-commit       # Run pre-commit checks
make all              # Format, vet, test, build
```

### Dependencies

```bash
make deps             # Download dependencies
make deps-update      # Update all dependencies
make deps-graph       # Show dependency tree
make deps-why PKG=x   # Why is package X needed?
```

### Setup

```bash
make install-tools    # Install dev tools (staticcheck, golangci-lint)
make install-hooks    # Install git pre-commit hooks
make info             # Show project information
make help             # Show all commands
```

## Testing Strategy

### 1. Unit Tests

Write tests for all packages:

```go
// user_test.go
func TestNewUser(t *testing.T) {
    u := NewUser("Alice", "alice@example.com")
    if u.Name != "Alice" {
        t.Errorf("expected Alice, got %s", u.Name)
    }
}
```

### 2. Table-Driven Tests

Use for multiple test cases:

```go
func TestIsValidEmail(t *testing.T) {
    tests := []struct {
        name  string
        email string
        want  bool
    }{
        {"valid", "user@example.com", true},
        {"invalid", "not-email", false},
        {"empty", "", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            u := &User{Email: tt.email}
            if got := u.IsValidEmail(); got != tt.want {
                t.Errorf("got %v, want %v", got, tt.want)
            }
        })
    }
}
```

### 3. Always Test with Race Detection

Race conditions are common in concurrent Go code:

```bash
# Before every commit
make test-race

# Build with race detector for debugging
go build -race -o bin/app-race ./main.go
```

### 4. Coverage Reports

Track test coverage:

```bash
make test-cover
# Opens coverage.html showing line-by-line coverage
```

Aim for:
- 80%+ coverage for critical code
- 70%+ overall coverage
- 100% coverage for security-critical functions

### 5. Benchmarks

Write benchmarks for performance-critical code:

```go
func BenchmarkIsValidEmail(b *testing.B) {
    u := &User{Email: "user@example.com"}
    for i := 0; i < b.N; i++ {
        u.IsValidEmail()
    }
}
```

Run with:
```bash
make test-bench
```

## Linting and Code Quality

### golangci-lint Configuration

The `.golangci.yml` file includes 40+ linters:

**Security:**
- `gosec` - Security vulnerabilities
- `errcheck` - Unchecked errors

**Bugs:**
- `govet` - Suspicious constructs
- `staticcheck` - Advanced analysis
- `nilnil` - Nil error with nil value
- `nilerr` - Returning nil error incorrectly

**Performance:**
- `bodyclose` - Unclosed HTTP bodies
- `prealloc` - Pre-allocatable slices

**Style:**
- `gofmt` - Standard formatting
- `gofumpt` - Stricter formatting
- `goimports` - Import organization
- `revive` - Style and best practices

**Complexity:**
- `gocyclo` - Cyclomatic complexity
- `gocognit` - Cognitive complexity
- `funlen` - Function length
- `nestif` - Deep nesting

### Running Linters

```bash
# Run all linters
make lint

# Auto-fix issues
make lint-fix

# Run specific linter
golangci-lint run --disable-all --enable=errcheck
```

### Common Lint Fixes

1. **Unchecked errors:**
   ```go
   // Bad
   file.Close()

   // Good
   if err := file.Close(); err != nil {
       return fmt.Errorf("close file: %w", err)
   }
   ```

2. **Error wrapping:**
   ```go
   // Bad
   return errors.New("failed")

   // Good
   return fmt.Errorf("parse user: %w", err)
   ```

3. **Exported functions need documentation:**
   ```go
   // NewUser creates a new User with the given name and email.
   func NewUser(name, email string) *User {
       // ...
   }
   ```

## Git Hooks

### Pre-commit Hook

Automatically runs before every commit:

1. **Format check** - Ensures code is `gofmt`-ed
2. **go vet** - Checks for suspicious code
3. **Module tidy** - Ensures go.mod is tidy
4. **staticcheck** - Static analysis (if installed)
5. **golangci-lint** - Comprehensive linting (if installed)
6. **Race detection tests** - Catches concurrency bugs

### Installing Hooks

```bash
make install-hooks
```

### Skipping Hooks

Only when absolutely necessary:

```bash
git commit --no-verify -m "message"
```

## CI/CD Pipeline

### GitHub Actions Workflow

Located at `.github/workflows/ci.yml`, runs on:
- Push to main/master
- Pull requests
- Manual trigger

### Jobs

1. **Test** - Multi-platform testing
   - Linux, macOS, Windows
   - Go 1.25.x and 1.24.x
   - Race detection
   - Coverage reporting

2. **Lint** - Code quality
   - golangci-lint with full config

3. **Format** - Code formatting
   - gofmt check
   - go vet

4. **Tidy** - Module check
   - Ensures go.mod is tidy

5. **Security** - Security scanning
   - gosec security scanner
   - SARIF upload to GitHub

6. **Build** - Multi-platform builds
   - Linux (amd64, arm64)
   - macOS (amd64, arm64)
   - Windows (amd64)

7. **Staticcheck** - Advanced analysis

8. **Summary** - Results summary

### Running CI Locally

```bash
# Run the same checks as CI
make ci

# This runs:
# - go mod tidy
# - formatting
# - go vet
# - linting
# - race detection tests
# - staticcheck
```

### Build Artifacts

After CI runs, downloadable binaries are available for 7 days:
- `projectShell-linux-amd64`
- `projectShell-linux-arm64`
- `projectShell-darwin-amd64`
- `projectShell-darwin-arm64`
- `projectShell-windows-amd64.exe`

## Building and Releasing

### Local Builds

```bash
# Current platform
make build
./bin/projectShell

# All platforms
make build-all
ls bin/

# With version info
VERSION=v1.0.0 make build
```

### Docker Builds (Optional)

```bash
make docker-build
make docker-run
```

### Release Process

1. **Prepare release**
   ```bash
   # Update version
   git tag v1.0.0

   # Ensure all checks pass
   make ci
   ```

2. **Push tag**
   ```bash
   git push origin v1.0.0
   ```

3. **GitHub Actions** automatically:
   - Runs all checks
   - Builds binaries
   - Creates artifacts

4. **Create GitHub Release**
   - Download artifacts from CI
   - Create release on GitHub
   - Upload binaries

## Best Practices Summary

### Always Do

1. **Run `make fmt`** frequently while coding
2. **Test with race detection** before commits: `make test-race`
3. **Run `make audit`** before pushing
4. **Write tests** for new code
5. **Document exported functions**
6. **Wrap errors** with context: `fmt.Errorf("...: %w", err)`
7. **Use pre-commit hooks** (don't skip them)
8. **Review linter output** and fix issues

### Never Do

1. **Never ignore errors**: `_, _ = something()`
2. **Never skip tests** in CI/CD
3. **Never commit without formatting**: run `make fmt`
4. **Never merge** without passing CI
5. **Never use `//nolint`** without good reason and comment
6. **Never commit** with failing race detector
7. **Never push** without running `make audit` first

### Code Review Checklist

Before submitting PR:
- [ ] All tests pass with race detection
- [ ] Code is formatted (`make fmt`)
- [ ] Linters pass (`make lint`)
- [ ] Coverage maintained or improved
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No security issues (`gosec`)
- [ ] go.mod is tidy

## Troubleshooting

### Tests Fail with Race Detector

**Problem:** Race condition detected

**Solution:**
1. Read the race detector output carefully
2. Use proper synchronization:
   - Mutexes for shared state
   - Channels for communication
   - Atomic operations for counters
3. Avoid sharing memory between goroutines

### Linter Errors

**Problem:** Too many linter errors

**Solution:**
```bash
# Auto-fix what can be fixed
make lint-fix

# Fix remaining issues manually
make lint

# Disable specific check if necessary (rarely)
//nolint:linter-name // reason why this is needed
```

### Pre-commit Hook Fails

**Problem:** Hook blocks commit

**Solution:**
1. Run checks individually to find the issue:
   ```bash
   make fmt
   make vet
   make tidy
   make lint
   make test-race
   ```
2. Fix the issues
3. Try committing again

### CI Fails

**Problem:** CI passes locally but fails in GitHub

**Solution:**
1. Run CI checks locally: `make ci`
2. Check for platform-specific issues
3. Review CI logs in GitHub Actions
4. Test on the failing platform if possible

## Quick Reference Card

```bash
# Daily workflow
make fmt && make test-short    # During development
make audit                     # Before commit
git commit -m "message"        # Hooks run automatically
git push                       # CI runs automatically

# When things go wrong
make lint-fix                  # Fix linting issues
make clean && make build       # Clean build
go clean -modcache && make deps # Fix module issues

# Information
make help                      # All commands
make info                      # Project info
cat DEVELOPMENT.md             # Full dev guide
```

## Resources

- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [golangci-lint Linters](https://golangci-lint.run/usage/linters/)
- [Go Testing](https://golang.org/pkg/testing/)
- [Race Detector](https://golang.org/doc/articles/race_detector.html)

---

**Remember:** A good workflow prevents bugs before they happen!
