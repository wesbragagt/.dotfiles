.PHONY: help build test clean dev ci prod

# Default target
help:
	@echo "Neovim Nix Docker Development"
	@echo "=============================="
	@echo ""
	@echo "Available commands:"
	@echo "  build     - Build all Docker images"
	@echo "  test      - Run minimal test"
	@echo "  dev       - Start development environment"
	@echo "  ci        - Run CI tests"
	@echo "  prod      - Build production image"
	@echo "  clean     - Clean up containers and images"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make test          # Quick test"
	@echo "  make dev           # Interactive development"
	@echo "  make ci            # Full CI pipeline"

# Build all images
build:
	@echo "🏗️  Building all Docker images..."
	docker-compose build
	@echo "✅ Build complete"

# Run minimal test
test:
	@echo "🧪 Running minimal test..."
	docker-compose up neovim-test
	@echo "✅ Test complete"

# Start development environment
dev:
	@echo "🚀 Starting development environment..."
	docker-compose run --rm neovim-dev

# Run CI tests
ci:
	@echo "🔬 Running CI tests..."
	docker-compose --profile ci up neovim-ci
	@echo "✅ CI complete"

# Build production image
prod:
	@echo "🏭 Building production image..."
	docker-compose --profile production build neovim-prod
	@echo "✅ Production build complete"

# Clean up
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down --remove-orphans 2>/dev/null || true
	docker system prune -f
	@echo "✅ Clean complete"

# Quick commands for common tasks
quick-test: test
quick-dev: dev
quick-ci: ci