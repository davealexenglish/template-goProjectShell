# Development Guide

This document provides comprehensive guidelines for developing, testing, and maintaining this Go project.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Quality](#code-quality)
- [Testing](#testing)
- [Building](#building)
- [Tools](#tools)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required

- **Go 1.25+**: Install from [golang.org](https://golang.org/dl/)
- **Make**: Should be pre-installed on macOS/Linux, Windows users can use [chocolatey](https://chocolatey.org/) or WSL

### Recommended

- **golangci-lint**: Comprehensive linter
  ```bash
  # macOS
  brew install golangci-lint

  # Linux/macOS/Windows (binary)
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

  # Or use go install
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  ```

- **staticcheck**: Additional static analysis
  ```bash
  go install honnef.co/go/tools/cmd/staticcheck@latest
  ```

### Optional

- **Docker**: For containerized builds and deployment
- **VS Code** with Go extension, or **GoLand** IDE

## Getting Started

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/davealexenglish/projectShell.git
cd projectShell

# Download dependencies
make deps

# Install development tools
make install-tools

# Install git hooks (recommended)
make install-hooks
```

### 2. Verify Setup

```bash
# Display project information
make info

# Run a quick health check
make audit
```

### 3. Run the Application

```bash
# Run directly (development)
make run

# Or build and run the binary
make build
./bin/projectShell
```

## Development Workflow

### Standard Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes**
   - Write code following [Go best practices](#best-practices)
   - Add tests for new functionality
   - Update documentation as needed

3. **Run quality checks**
   ```bash
   # Format code
   make fmt

   # Run linters
   make lint

   # Run tests
   make test

   # Or run everything at once
   make audit
   ```

4. **Commit changes**
   ```bash
   git add .
   git commit -m "Add feature: description"
   # Pre-commit hooks will run automatically if installed
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/my-new-feature
   ```

### Quick Development Commands

```bash
# Format all Go files
make fmt

# Run application
make run

# Run tests quickly
make test-short

# Run tests with coverage
make test-cover

# Fix linting issues automatically
make lint-fix

# Build binary
make build

# Clean build artifacts
make clean
```

## Code Quality

### Formatting

This project uses strict formatting rules:

- **gofmt**: Standard Go formatting
- **gofumpt**: Stricter formatting (superset of gofmt)
- **goimports**: Automatic import organization

```bash
# Format all code
make fmt
```

**Editor Integration:**
- VS Code: Install the Go extension and enable format-on-save
- GoLand: Enable gofmt in Settings → Go → Formatting

### Linting

We use `golangci-lint` with a comprehensive configuration (`.golangci.yml`):

```bash
# Run all linters
make lint

# Run and auto-fix issues
make lint-fix

# Run specific checks
make vet          # Go vet
make staticcheck  # Static analysis
```

**Key Linters Enabled:**
- `errcheck`: Unchecked error handling
- `gosec`: Security vulnerabilities
- `govet`: Suspicious constructs
- `staticcheck`: Advanced static analysis
- `revive`: Style and best practices
- `gocritic`: Additional diagnostics
- And many more (see `.golangci.yml`)

### Pre-commit Hooks

Git hooks automatically run quality checks before commits:

```bash
# Install hooks
make install-hooks

# Hooks will run on every commit and check:
# - Code formatting (gofmt)
# - Go vet
# - Module tidiness
# - Linters (if installed)
# - Tests with race detection
```

**Bypass hooks** (not recommended):
```bash
git commit --no-verify
```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run tests with coverage report
make test-cover
# Opens coverage.html in browser

# Run only short tests (skip long-running tests)
make test-short

# Run benchmarks
make test-bench

# Run with race detection (important!)
make test-race
```

### Writing Tests

Follow Go testing conventions:

```go
// user_test.go
package user

import "testing"

func TestNewUser(t *testing.T) {
    u := NewUser("Alice", "alice@example.com")

    if u.Name != "Alice" {
        t.Errorf("expected name Alice, got %s", u.Name)
    }

    if !u.IsValidEmail() {
        t.Error("expected valid email")
    }
}

// Benchmark example
func BenchmarkIsValidEmail(b *testing.B) {
    u := NewUser("Alice", "alice@example.com")

    for i := 0; i < b.N; i++ {
        u.IsValidEmail()
    }
}
```

### Race Detection

Always run tests with race detection enabled, especially before committing:

```bash
make test-race
```

**Why?** Race conditions are one of the most common bugs in concurrent Go programs.

**Building with race detector:**
```bash
go build -race -o bin/projectShell-race ./main.go
```

## Building

### Local Build

```bash
# Build for current platform
make build

# Run the binary
./bin/projectShell

# Install to $GOPATH/bin
make install
```

### Cross-Platform Build

```bash
# Build for multiple platforms
make build-all

# Creates binaries:
# - bin/projectShell-linux-amd64
# - bin/projectShell-darwin-amd64
# - bin/projectShell-darwin-arm64
# - bin/projectShell-windows-amd64.exe
```

### Build with Version Info

Version and build time are automatically embedded:

```go
// In your main.go, add:
var (
    Version   = "dev"
    BuildTime = "unknown"
)

func main() {
    fmt.Printf("Version: %s, Built: %s\n", Version, BuildTime)
    // ... rest of your code
}
```

Build flags are set in the Makefile using `-ldflags`.

### Docker Build (Optional)

```bash
# Build Docker image
make docker-build

# Run in Docker
make docker-run
```

Example `Dockerfile`:

```dockerfile
FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN go build -o projectShell ./main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/projectShell .
CMD ["./projectShell"]
```

## Tools

### Installed Tools

After running `make install-tools`, you'll have:

- **staticcheck**: Advanced static analysis
- **golangci-lint**: Comprehensive linter suite

### Useful Go Tools

```bash
# View dependency graph
make deps-graph

# Explain why a package is needed
make deps-why PKG=github.com/google/uuid

# Update all dependencies
make deps-update
```

### Editor Setup

#### VS Code

Recommended extensions:
- [Go](https://marketplace.visualstudio.com/items?itemName=golang.go)

Settings (`.vscode/settings.json`):
```json
{
  "go.useLanguageServer": true,
  "go.lintTool": "golangci-lint",
  "go.lintOnSave": "package",
  "editor.formatOnSave": true,
  "go.buildOnSave": "package",
  "go.testFlags": ["-race"],
  "go.coverOnSave": true
}
```

#### GoLand

1. Enable gofmt: Settings → Go → Formatting
2. Enable golangci-lint: Settings → Go → Linter
3. Enable save actions: Settings → Tools → Actions on Save

## Best Practices

### Code Style

1. **Follow effective Go guidelines**: [Effective Go](https://golang.org/doc/effective_go)

2. **Use meaningful names**
   ```go
   // Good
   func ParseUser(data []byte) (*User, error)

   // Bad
   func Parse(d []byte) (*User, error)
   ```

3. **Keep functions small and focused**
   - Aim for < 50 lines
   - Single responsibility principle

4. **Always handle errors**
   ```go
   // Good
   if err != nil {
       return fmt.Errorf("failed to parse user: %w", err)
   }

   // Bad
   _ = someFunction() // Never ignore errors
   ```

5. **Use early returns**
   ```go
   // Good
   func DoSomething(x int) error {
       if x < 0 {
           return errors.New("x must be positive")
       }
       // ... main logic
       return nil
   }
   ```

### Error Handling

1. **Wrap errors with context**
   ```go
   if err != nil {
       return fmt.Errorf("failed to open file %s: %w", filename, err)
   }
   ```

2. **Use sentinel errors**
   ```go
   var (
       ErrNotFound = errors.New("user not found")
       ErrInvalid  = errors.New("invalid input")
   )
   ```

3. **Check error types when needed**
   ```go
   if errors.Is(err, ErrNotFound) {
       // Handle not found
   }
   ```

### Concurrency

1. **Always test with race detector**
   ```bash
   make test-race
   ```

2. **Use channels for communication**
   ```go
   // Prefer channels over shared memory
   results := make(chan Result)
   go worker(results)
   ```

3. **Use sync package for synchronization**
   ```go
   var mu sync.Mutex
   mu.Lock()
   defer mu.Unlock()
   // critical section
   ```

4. **Use context for cancellation**
   ```go
   func DoWork(ctx context.Context) error {
       select {
       case <-ctx.Done():
           return ctx.Err()
       case <-time.After(time.Second):
           // do work
       }
       return nil
   }
   ```

### Testing

1. **Table-driven tests**
   ```go
   func TestIsValidEmail(t *testing.T) {
       tests := []struct {
           name  string
           email string
           want  bool
       }{
           {"valid", "user@example.com", true},
           {"invalid", "not-an-email", false},
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

2. **Use testify for assertions** (optional)
   ```go
   import "github.com/stretchr/testify/assert"

   assert.Equal(t, expected, actual)
   assert.NoError(t, err)
   ```

3. **Test edge cases**
   - Empty inputs
   - Nil values
   - Boundary conditions
   - Error conditions

### Documentation

1. **Document exported symbols**
   ```go
   // User represents a system user with authentication details.
   type User struct {
       // ID is the unique identifier for the user.
       ID string
   }

   // NewUser creates a new User with the given name and email.
   // It returns an error if the email is invalid.
   func NewUser(name, email string) (*User, error) {
       // ...
   }
   ```

2. **Use examples**
   ```go
   // Example usage in documentation
   func ExampleNewUser() {
       u := NewUser("Alice", "alice@example.com")
       fmt.Println(u.Name)
       // Output: Alice
   }
   ```

## Troubleshooting

### Common Issues

#### "golangci-lint not found"

Install it:
```bash
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

Make sure `$GOPATH/bin` is in your `PATH`:
```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

#### "Tests failing with race detector"

Race conditions detected. Fix by:
1. Using proper synchronization (mutexes, channels)
2. Avoiding shared mutable state
3. Using atomic operations when appropriate

#### "Module not found" errors

```bash
# Clean module cache
go clean -modcache

# Re-download dependencies
make deps

# Verify modules
go mod verify
```

#### "Pre-commit hook failing"

Run checks individually to identify the issue:
```bash
make fmt
make vet
make tidy
make lint
make test
```

#### Build cache issues

```bash
# Clean build cache
go clean -cache

# Rebuild
make clean
make build
```

### Getting Help

```bash
# View all available make commands
make help

# Display project info
make info
```

For more help:
- Go Documentation: [golang.org/doc](https://golang.org/doc/)
- Effective Go: [golang.org/doc/effective_go](https://golang.org/doc/effective_go)
- Go Code Review Comments: [go.dev/wiki/CodeReviewComments](https://go.dev/wiki/CodeReviewComments)

---

## Quick Reference

### Essential Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make run` | Run the application |
| `make test` | Run all tests |
| `make test-race` | Run tests with race detection |
| `make lint` | Run all linters |
| `make lint-fix` | Auto-fix linting issues |
| `make fmt` | Format all code |
| `make build` | Build binary |
| `make audit` | Run all quality checks |
| `make clean` | Clean build artifacts |
| `make install-hooks` | Install git hooks |

### CI/CD Command

```bash
# Run the same checks as CI
make ci
```

This runs: tidy, fmt, vet, lint, test-race, staticcheck

---

**Happy coding! 🚀**
