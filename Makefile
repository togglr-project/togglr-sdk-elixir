.PHONY: install generate post-generate test lint format clean docs run-example-simple run-example-advanced regenerate

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
		echo "Copying generated files to lib/sdkapi..."; \
		rm -rf lib/sdkapi/; \
		mkdir -p lib/sdkapi/; \
		cp -r internal/generated/lib/sdkapi/* lib/sdkapi/; \
		echo "Applying necessary modifications..."; \
		$(MAKE) post-generate; \
		echo "Cleaning up temporary files..."; \
		rm -rf internal/generated/; \
		echo "Generation complete!"; \
	else \
		echo "openapi-generator-cli not found. Please install it first:"; \
		echo "  npm install -g @openapitools/openapi-generator-cli"; \
		echo "  or"; \
		echo "  brew install openapi-generator"; \
	fi

# Apply post-generation modifications
post-generate:
	@./scripts/post-generate.sh

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
	rm -rf generated/

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

# Full regeneration (clean + generate)
regenerate: clean generate
	@echo "Full regeneration complete!"
