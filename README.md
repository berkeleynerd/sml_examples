# sml_examples

Example binaries and integration demos for the SML core library.

- `sml_example`: DOM parse/build/modify/serialize demo
- `schema_validation_example`: schema validation walkthrough
- `test_schema_loader`: file-based schema load + validation (uses local fixtures/)

## Usage

```bash
# Build examples
alr build
# Or use GPR directly
alr exec -- gprbuild -P examples.gpr

# Run via Alire (picks env/pins)
alr run sml_example
alr run schema_validation_example
alr run test_schema_loader  # looks in fixtures/

# CI-style: run all examples as tests
alr test
```

## Depend on these crates

alire.toml:

```toml
[[depends-on]]
sml = "=0.1.0"

[[depends-on]]
sml_io = "=0.1.0"
```
