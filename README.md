# MyProject

A sample Go project demonstrating Go modules, package structure, and testing.

## Project Structure

```
myproject/
├── go.mod              # Go module definition
├── go.sum              # Module checksums (auto-generated)
├── main.go             # Application entry point
├── pkg/
│   └── user/
│       ├── user.go     # User package implementation
│       └── user_test.go # User package tests
└── README.md           # This file
```

## Prerequisites

- Go 1.21 or higher
- Git (for module management)

## Getting Started

### 1. Initialize the Project

First, clone or create the project directory with the files provided. Update the module path in `go.mod` to match your repository:

```bash
# Edit go.mod and replace:
# module github.com/davealexenglish/projectShell
# with your actual repository path
```

### 2. Install Dependencies

The project uses the `github.com/google/uuid` package for generating unique identifiers. Install all dependencies with:

```bash
go mod download
```

Or let Go automatically download dependencies when you build:

```bash
go mod tidy
```

This command will:
- Download any missing modules
- Remove unused modules
- Update `go.sum` with checksums

## Building

Build the project executable:

```bash
go build -o myproject
```

This creates an executable named `myproject` (or `myproject.exe` on Windows).

### Build for Different Platforms

```bash
# For Linux
GOOS=linux GOARCH=amd64 go build -o myproject-linux

# For Windows
GOOS=windows GOARCH=amd64 go build -o myproject.exe

# For macOS
GOOS=darwin GOARCH=amd64 go build -o myproject-mac
```

## Running

Run the project directly without building:

```bash
go run main.go
```

Or run the built executable:

```bash
./myproject
```

## Testing

### Run All Tests

```bash
go test ./...
```

### Run Tests with Verbose Output

```bash
go test -v ./...
```

### Run Tests in a Specific Package

```bash
go test ./pkg/user
```

### Run a Specific Test

```bash
go test -v -run TestNewUser ./pkg/user
```

### Run Tests with Coverage

```bash
go test -cover ./...
```

### Generate Coverage Report

```bash
# Generate coverage profile
go test -coverprofile=coverage.out ./...

# View coverage in terminal
go tool cover -func=coverage.out

# Generate HTML coverage report
go tool cover -html=coverage.out -o coverage.html
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
