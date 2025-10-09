.PHONY: install generate test lint format clean docs run-example-simple run-example-advanced

# Install dependencies
install:
	mix deps.get

# Generate client from OpenAPI spec
generate:
	@echo "Generating Elixir client from OpenAPI specification..."
	@if command -v openapi-generator-cli >/dev/null 2>&1; then \
		openapi-generator-cli generate \
			-g elixir \
			-i specs/sdk.yml \
			-o internal/generated \
			--additional-properties=packageName=TogglrSdk.Generated,packageVersion=1.0.0; \
	else \
		echo "openapi-generator-cli not found. Please install it first:"; \
		echo "  npm install -g @openapitools/openapi-generator-cli"; \
		echo "  or"; \
		echo "  brew install openapi-generator"; \
	fi

# Run tests
test:
	mix test

# Run linting
lint:
	mix credo --strict
	mix dialyzer

# Format code
format:
	mix format

# Clean build artifacts
clean:
	mix clean
	rm -rf _build/
	rm -rf deps/
	rm -rf internal/generated/

# Generate documentation
docs:
	mix docs

# Development setup
dev-setup: install generate
	@echo "Development environment setup complete!"

# Build package
build: test lint
	mix hex.build

# Run simple example
run-example-simple:
	mix run examples/simple_example.exs

# Run advanced example
run-example-advanced:
	mix run examples/advanced_example.exs
