# sml_examples

Example binaries and integration demos for the SML core library.

- `sml_example`: DOM parse/build/modify/serialize demo
- `schema_validation_example`: schema validation walkthrough
- `test_schema_loader`: file-based schema load + validation (uses local fixtures/)

## Usage

```bash
# Link local core + io during development
alr develop --use ../sml --use ../sml_io

# Build examples
alr build
alr exec -- gprbuild -P examples.gpr

# Run
bin/sml_example
bin/schema_validation_example
bin/test_schema_loader  # looks in fixtures/
```

## Depend on these crates

alire.toml:

```toml
[dependencies]
sml = "^0.1.0"
sml_io = "^0.1.0"
```
