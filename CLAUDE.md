# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python development environment template using **uv** (fast Python package manager), **Ruff** (linter/formatter), and **ty** (type checker). The repository serves dual purposes:
1. A template for starting new Python projects
2. A reusable `tools/` package with production-ready utilities (Logger, Config, Timer)

## Development Commands

### Package Management
```bash
# Install dependencies
uv sync

# Add new dependency
uv add <package>

# Add dev dependency
uv add --dev <package>

# Remove dependency
uv remove <package>
```

### Testing
```bash
# Run all tests with coverage (75% minimum required)
uv run pytest

# Run specific test file
uv run pytest tests/tools/test__logger.py

# Run with XML output for CI
uv run pytest --cov-report=xml --junitxml=junit.xml
```

### Linting & Formatting
```bash
# Format code with Ruff
uv run ruff format .

# Lint with Ruff
uv run ruff check . --fix

# Type check with ty
uv run ty check
```

### Pre-commit Hooks
```bash
# Install hooks
uv run pre-commit install

# Run all hooks manually
uv run pre-commit run --all-files

# Run specific hook
uv run pre-commit run ruff-format
```

## Architecture

### Core Modules

The `tools/` package provides three main utility modules:
- **tools/logger/**: Dual-mode logging — `LogType.LOCAL` (colored console) or `LogType.GOOGLE_CLOUD` (structured JSON). Switch via `Settings.IS_LOCAL`.
- **tools/config/**: Pydantic `Settings` class. Loads from `.env` (versioned) then `.env.local` (gitignored local overrides).
- **tools/tracer/**: `Timer` usable as decorator or context manager; logs execution time at DEBUG level.

### Test Structure

Tests in `tests/tools/` mirror the package structure:
- **Naming convention**: `test__*.py` (double underscore — non-obvious, required)
- **Coverage requirement**: 75% minimum (including branch coverage)

## Pull Request Process

For comprehensive contribution guidelines, including detailed steps for creating and reviewing Pull Requests, please refer to [CONTRIBUTING.md](CONTRIBUTING.md) in the repository root.

**Code of Conduct**: All contributors must follow our [Code of Conduct](CODE_OF_CONDUCT.md). We maintain a welcoming, inclusive, and harassment-free environment for everyone.

## Environment Variables

Critical environment variables (set in `.env.local`):
- `IS_LOCAL`: Boolean flag for local vs production (affects logging, configuration)
- `DEBUG`: Boolean for debug mode
- FastAPI settings: `TITLE`, `VERSION`, `API_PREFIX_V1`, etc.

## Important Notes

- **Coverage is enforced**: Tests must maintain 75% coverage (configured in pytest.ini)
- **uv replaces pip/poetry**: Use `uv add` not `pip install`, use `uv.lock` not `requirements.txt`
- **Ruff replaces multiple tools**: No need for Black, isort, Flake8, etc.
- **Test naming**: Use `test__*.py` pattern (double underscore)
- **Type checking**: ty checks both the `tools/` and `tests/` packages

## Template Usage Pattern

When using this as a template for a new project:
1. Update `pyproject.toml` with new project name/description
2. Modify or extend `tools/config/settings.py` for project-specific configuration
3. Use the utilities from `tools/` or remove if not needed
4. Update `.env` with base configuration, `.env.local` with local overrides
5. Customize Ruff rules in `ruff.toml` if needed (but start with defaults)
