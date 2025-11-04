# ProjectShell

A professional Go project template with comprehensive development workflow, testing, and CI/CD setup.

## Quick Start

```bash
# Clone and setup
git clone https://github.com/davealexenglish/projectShell.git
cd projectShell

# Install dependencies and tools
make deps
make install-tools

# Install git hooks (recommended)
make install-hooks

# Run the application
make run

# Run all quality checks
make audit
```

## Features

- **Complete Makefile**: 30+ commands for development, testing, and building
- **Comprehensive Linting**: golangci-lint with 40+ enabled linters
- **Pre-commit Hooks**: Automated quality checks before every commit
- **GitHub Actions CI/CD**: Multi-platform testing and building
- **Race Detection**: Built-in race condition detection
- **Coverage Reports**: HTML coverage reports with one command
- **Cross-platform Builds**: Build for Linux, macOS, and Windows
- **Developer Documentation**: Complete development guide

## Documentation

- **[DEVELOPMENT.md](DEVELOPMENT.md)**: Complete development guide with best practices
- **[Makefile](Makefile)**: All available commands (run `make help`)
- **[.golangci.yml](.golangci.yml)**: Linter configuration

## Project Structure

```
projectShell/
├── .github/
│   └── workflows/
│       └── ci.yml           # GitHub Actions CI/CD
├── .golangci.yml            # Comprehensive linter config
├── .editorconfig            # Editor configuration
├── scripts/
│   └── pre-commit.sh        # Git pre-commit hook
├── pkg/
│   └── user/
│       ├── user.go          # User package
│       └── user_test.go     # Tests
├── main.go                  # Application entry point
├── go.mod                   # Go module definition
├── Makefile                 # Development workflow
├── DEVELOPMENT.md           # Developer guide
└── README.md                # This file
```

## Quick Reference

### Essential Commands

```bash
make help         # Show all available commands
make run          # Run the application
make test         # Run all tests
make test-race    # Run tests with race detection
make test-cover   # Generate coverage report
make lint         # Run all linters
make lint-fix     # Auto-fix linting issues
make fmt          # Format all code
make build        # Build binary
make audit        # Run all quality checks
make ci           # Run CI checks locally
```

### Development Workflow

1. **Make changes** to your code
2. **Run checks**: `make audit` or `make pre-commit`
3. **Commit**: Git hooks will run automatically
4. **Push**: CI will run in GitHub Actions

## Testing

```bash
# Run all tests
make test

# Run with race detection (recommended)
make test-race

# Generate coverage report
make test-cover
# Opens coverage.html in browser

# Run benchmarks
make test-bench
```

## Building

```bash
# Build for current platform
make build

# Build for all platforms
make build-all

# Install to $GOPATH/bin
make install
```

## Dependencies

This project uses the following external modules:

- **github.com/google/uuid** (v1.6.0): UUID generation library
  - Used for generating unique user identifiers
  - Provides RFC 4122 compliant UUIDs

## Adding New Dependencies

To add a new dependency:

```bash
# Simply import it in your code, then run:
go mod tidy

# Or explicitly add it:
go get github.com/some/package@version
```

## Project Features

### User Package

The `pkg/user` package provides:

- `User` struct with ID, Name, and Email fields
- `NewUser()` constructor that auto-generates UUIDs
- `IsValidEmail()` method for email validation
- `String()` method for user representation

### Example Usage

```go
package main

import (
    "fmt"
    "github.com/davealexenglish/projectShell/pkg/user"
)

func main() {
    u := user.NewUser("Alice", "alice@example.com")
    fmt.Println(u.String())
}
```

## Development Workflow

1. Make code changes
2. Run tests: `go test ./...`
3. Format code: `go fmt ./...`
4. Check for issues: `go vet ./...`
5. Update dependencies: `go mod tidy`
6. Build: `go build`

## Useful Commands

```bash
# Format all Go files
go fmt ./...

# Check for common mistakes
go vet ./...

# List all dependencies
go list -m all

# View module graph
go mod graph

# Verify dependencies
go mod verify

# Clean module cache
go clean -modcache
```

## License

MIT License (or specify your license)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
