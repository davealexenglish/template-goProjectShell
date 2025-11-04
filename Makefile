# Go Project Makefile
# This Makefile provides a complete development workflow for Go projects

# ==================================================================================== #
# VARIABLES
# ==================================================================================== #

# Binary name
BINARY_NAME=projectShell
MAIN_PATH=./main.go

# Go related variables
GOBASE=$(shell pwd)
GOBIN=$(GOBASE)/bin
GOFILES=$(wildcard *.go)

# Module name from go.mod
MODULE=$(shell go list -m)

# Build variables
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)"

# Color output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m # No Color

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

.PHONY: help
## help: Display this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

.PHONY: audit
## audit: Run all quality control checks (tidy, fmt, vet, test, staticcheck)
audit: tidy fmt vet test staticcheck
	@echo "$(GREEN)✓ Audit complete$(NC)"

.PHONY: tidy
## tidy: Tidy and verify module dependencies
tidy:
	@echo "$(YELLOW)Tidying module dependencies...$(NC)"
	go mod tidy
	go mod verify
	@echo "$(GREEN)✓ Dependencies tidied$(NC)"

.PHONY: fmt
## fmt: Format all Go files
fmt:
	@echo "$(YELLOW)Formatting Go files...$(NC)"
	go fmt ./...
	@echo "$(GREEN)✓ Files formatted$(NC)"

.PHONY: vet
## vet: Run go vet for suspicious constructs
vet:
	@echo "$(YELLOW)Running go vet...$(NC)"
	go vet ./...
	@echo "$(GREEN)✓ Vet passed$(NC)"

.PHONY: staticcheck
## staticcheck: Run staticcheck linter
staticcheck:
	@echo "$(YELLOW)Running staticcheck...$(NC)"
	@which staticcheck > /dev/null || (echo "$(RED)✗ staticcheck not installed. Run: go install honnef.co/go/tools/cmd/staticcheck@latest$(NC)" && exit 1)
	staticcheck ./...
	@echo "$(GREEN)✓ Staticcheck passed$(NC)"

.PHONY: lint
## lint: Run golangci-lint with all enabled linters
lint:
	@echo "$(YELLOW)Running golangci-lint...$(NC)"
	@which golangci-lint > /dev/null || (echo "$(RED)✗ golangci-lint not installed. See: https://golangci-lint.run/usage/install/$(NC)" && exit 1)
	golangci-lint run ./...
	@echo "$(GREEN)✓ Linting passed$(NC)"

.PHONY: lint-fix
## lint-fix: Run golangci-lint and auto-fix issues where possible
lint-fix:
	@echo "$(YELLOW)Running golangci-lint with auto-fix...$(NC)"
	golangci-lint run --fix ./...
	@echo "$(GREEN)✓ Linting and fixes complete$(NC)"

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

.PHONY: run
## run: Run the application
run:
	@echo "$(YELLOW)Running application...$(NC)"
	go run $(MAIN_PATH)

.PHONY: build
## build: Build the application binary
build:
	@echo "$(YELLOW)Building binary...$(NC)"
	go build $(LDFLAGS) -o $(GOBIN)/$(BINARY_NAME) $(MAIN_PATH)
	@echo "$(GREEN)✓ Binary built at $(GOBIN)/$(BINARY_NAME)$(NC)"

.PHONY: build-all
## build-all: Build binaries for multiple platforms
build-all:
	@echo "$(YELLOW)Building for multiple platforms...$(NC)"
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(GOBIN)/$(BINARY_NAME)-linux-amd64 $(MAIN_PATH)
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(GOBIN)/$(BINARY_NAME)-darwin-amd64 $(MAIN_PATH)
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(GOBIN)/$(BINARY_NAME)-darwin-arm64 $(MAIN_PATH)
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(GOBIN)/$(BINARY_NAME)-windows-amd64.exe $(MAIN_PATH)
	@echo "$(GREEN)✓ Multi-platform builds complete$(NC)"

.PHONY: install
## install: Install the application binary to GOPATH/bin
install:
	@echo "$(YELLOW)Installing binary...$(NC)"
	go install $(LDFLAGS) $(MAIN_PATH)
	@echo "$(GREEN)✓ Binary installed$(NC)"

.PHONY: clean
## clean: Clean build artifacts and caches
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	go clean
	rm -rf $(GOBIN)
	rm -rf coverage.out coverage.html
	@echo "$(GREEN)✓ Cleaned$(NC)"

# ==================================================================================== #
# TESTING
# ==================================================================================== #

.PHONY: test
## test: Run all tests
test:
	@echo "$(YELLOW)Running tests...$(NC)"
	go test -v -race -buildvcs ./...
	@echo "$(GREEN)✓ Tests passed$(NC)"

.PHONY: test-cover
## test-cover: Run tests with coverage report
test-cover:
	@echo "$(YELLOW)Running tests with coverage...$(NC)"
	go test -v -race -buildvcs -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)✓ Coverage report generated: coverage.html$(NC)"

.PHONY: test-short
## test-short: Run only short tests
test-short:
	@echo "$(YELLOW)Running short tests...$(NC)"
	go test -v -short -race -buildvcs ./...
	@echo "$(GREEN)✓ Short tests passed$(NC)"

.PHONY: test-bench
## test-bench: Run benchmark tests
test-bench:
	@echo "$(YELLOW)Running benchmarks...$(NC)"
	go test -bench=. -benchmem ./...
	@echo "$(GREEN)✓ Benchmarks complete$(NC)"

.PHONY: test-race
## test-race: Run tests with race detection (comprehensive)
test-race:
	@echo "$(YELLOW)Running race detection tests...$(NC)"
	go test -race -count=1 -timeout=30s ./...
	@echo "$(GREEN)✓ Race detection tests passed$(NC)"

# ==================================================================================== #
# DEPENDENCIES
# ==================================================================================== #

.PHONY: deps
## deps: Download and verify dependencies
deps:
	@echo "$(YELLOW)Downloading dependencies...$(NC)"
	go mod download
	go mod verify
	@echo "$(GREEN)✓ Dependencies ready$(NC)"

.PHONY: deps-update
## deps-update: Update all dependencies
deps-update:
	@echo "$(YELLOW)Updating dependencies...$(NC)"
	go get -u ./...
	go mod tidy
	@echo "$(GREEN)✓ Dependencies updated$(NC)"

.PHONY: deps-graph
## deps-graph: Show dependency graph
deps-graph:
	@echo "$(YELLOW)Generating dependency graph...$(NC)"
	go mod graph

.PHONY: deps-why
## deps-why: Show why a package is needed (usage: make deps-why PKG=package-name)
deps-why:
	@if [ -z "$(PKG)" ]; then echo "$(RED)✗ Usage: make deps-why PKG=package-name$(NC)"; exit 1; fi
	go mod why $(PKG)

# ==================================================================================== #
# TOOLS INSTALLATION
# ==================================================================================== #

.PHONY: install-tools
## install-tools: Install development tools
install-tools:
	@echo "$(YELLOW)Installing development tools...$(NC)"
	go install honnef.co/go/tools/cmd/staticcheck@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "$(GREEN)✓ Tools installed$(NC)"

# ==================================================================================== #
# GIT HOOKS
# ==================================================================================== #

.PHONY: install-hooks
## install-hooks: Install git pre-commit hooks
install-hooks:
	@echo "$(YELLOW)Installing git hooks...$(NC)"
	@mkdir -p .git/hooks
	@cp -f scripts/pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "$(GREEN)✓ Git hooks installed$(NC)"

# ==================================================================================== #
# DOCKER (OPTIONAL)
# ==================================================================================== #

.PHONY: docker-build
## docker-build: Build Docker image
docker-build:
	@echo "$(YELLOW)Building Docker image...$(NC)"
	docker build -t $(BINARY_NAME):$(VERSION) .
	@echo "$(GREEN)✓ Docker image built$(NC)"

.PHONY: docker-run
## docker-run: Run Docker container
docker-run:
	@echo "$(YELLOW)Running Docker container...$(NC)"
	docker run --rm $(BINARY_NAME):$(VERSION)

# ==================================================================================== #
# SPECIAL TARGETS
# ==================================================================================== #

.PHONY: all
## all: Run fmt, vet, test, and build
all: fmt vet test build
	@echo "$(GREEN)✓ All tasks complete$(NC)"

.PHONY: ci
## ci: Run all CI checks (used in CI/CD pipeline)
ci: tidy fmt vet lint test-race staticcheck
	@echo "$(GREEN)✓ CI checks passed$(NC)"

.PHONY: pre-commit
## pre-commit: Run pre-commit checks (fmt, vet, lint, test)
pre-commit: fmt vet lint test
	@echo "$(GREEN)✓ Pre-commit checks passed$(NC)"

.PHONY: info
## info: Display project information
info:
	@echo "Module: $(MODULE)"
	@echo "Version: $(VERSION)"
	@echo "Build Time: $(BUILD_TIME)"
	@echo "Go Version: $(shell go version)"
	@echo "Binary Name: $(BINARY_NAME)"
	@echo "Main Path: $(MAIN_PATH)"

# Default target
.DEFAULT_GOAL := help
