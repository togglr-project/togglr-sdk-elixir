# Development Guide

## OpenAPI Client Generation

This project uses OpenAPI Generator to generate the Elixir client from the OpenAPI specification.

### Process Overview

1. **Generation**: OpenAPI Generator creates files in `internal/generated/` (temporary directory)
2. **Copying**: Files are automatically copied from `internal/generated/lib/sdkapi/` to `lib/sdkapi/`
3. **Modifications**: Necessary modifications are applied automatically
4. **Cleanup**: Temporary `internal/generated/` directory is removed

### Available Commands

#### Generate API Client
```bash
make generate
```
- Generates client from `specs/sdk.yml`
- Copies files to `lib/sdkapi/`
- Applies necessary modifications
- Cleans up temporary files

#### Full Regeneration
```bash
make regenerate
```
- Cleans all generated files
- Runs full generation process
- Equivalent to `make clean && make generate`

#### Apply Modifications Only
```bash
make post-generate
```
- Applies modifications to existing `lib/sdkapi/` files
- Useful for testing modifications without full regeneration

### Automatic Modifications

The following modifications are applied automatically after generation:

1. **JSON Library**: `JSON.decode` → `Jason.decode` in `deserializer.ex`
2. **Type Guards**: Adds `when is_binary(json)` guard to `json_decode/1`
3. **Map Handling**: Adds function clause for already decoded maps

### Manual Modifications

If you need to make additional modifications to generated files:

1. Edit files in `lib/sdkapi/`
2. Test your changes
3. Consider adding modifications to `post-generate` target in `Makefile`

### Directory Structure

```
├── specs/
│   └── sdk.yml              # OpenAPI specification
├── internal/                 # Temporary (auto-removed)
│   └── generated/           # Generated files (temporary)
├── lib/
│   └── sdkapi/              # Working copy (used by project)
└── generated/               # Backup copy (optional)
```

### Troubleshooting

#### Generation Fails
- Ensure `openapi-generator-cli` is installed
- Check `specs/sdk.yml` for syntax errors
- Run `make clean` and try again

#### Modifications Not Applied
- Check `post-generate` target in `Makefile`
- Ensure sed commands are compatible with your system
- Run `make post-generate` manually

#### Files Not Copied
- Check that `internal/generated/lib/sdkapi/` exists
- Ensure copy commands in `Makefile` are correct
- Run `make generate` again

### Development Workflow

1. **Update OpenAPI spec** in `specs/sdk.yml`
2. **Run generation**: `make generate`
3. **Test changes**: `mix test`
4. **Commit changes** to `lib/sdkapi/`

### Notes

- `internal/generated/` is temporary and should not be committed
- `lib/sdkapi/` contains the working copy used by the project
- Always test after generation to ensure everything works
- Consider adding new modifications to `post-generate` target for consistency
