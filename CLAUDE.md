# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python development environment template using **uv** (fast Python package manager) and **Ruff** (linter/formatter). The repository serves dual purposes:
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

#### **tools/logger/** - Dual-Mode Logging System
- `Logger` class extends `logging.Logger` with environment-aware formatting
- **LogType.LOCAL**: Colored console output via `LocalFormatter` for development
- **LogType.GOOGLE_CLOUD**: Structured JSON via `GoogleCloudFormatter` for production
- Key pattern: Use `Settings.IS_LOCAL` to switch between modes automatically

```python
from tools.config import Settings
from tools.logger import Logger, LogType

settings = Settings()
logger = Logger(
    __name__,
    log_type=LogType.LOCAL if settings.IS_LOCAL else LogType.GOOGLE_CLOUD
)
```

#### **tools/config/** - Environment-Based Configuration
- `Settings` class uses Pydantic for type-safe configuration
- Loads from `.env` (version controlled) and `.env.local` (local overrides, in .gitignore)
- `FastAPIKwArgs` provides ready-to-use FastAPI initialization parameters
- Pattern: Extend `Settings` to add project-specific configuration fields

```python
from tools.config import Settings

settings = Settings()
api_url = settings.api_prefix_v1  # Loaded from environment
```

#### **tools/tracer/** - Performance Monitoring
- `Timer` class works as both decorator and context manager
- Automatically logs execution time in milliseconds at DEBUG level
- Uses the `Logger` module for output (inherits logging configuration)
- Pattern: Nest timers to measure both overall and component performance

```python
from tools.tracer import Timer

@Timer("full_operation")
def process():
    with Timer("step1"):
        do_step1()
    with Timer("step2"):
        do_step2()
```

### Test Structure

Tests in `tests/tools/` mirror the package structure:
- **Naming convention**: `test__*.py` (double underscore)
- **Coverage requirement**: 75% minimum (including branch coverage)
- **Test files exempt from**: `INP001` (namespace packages), `S101` (assert usage)

### Configuration Philosophy

**Ruff (ruff.toml)**:
- ALL rules enabled by default with specific exclusions
- Line length: 88 (Black-compatible)
- Target Python: 3.14
- Per-file ignores for test files

**ty (ty.toml)**:
- Includes `tools/` and `tests/` packages
- Excludes cache directories (`__pycache__`, `.pytest_cache`, `.ruff_cache`, `.venv`)

**pytest (pytest.ini)**:
- Coverage: 75% minimum with branch coverage
- Reports: HTML + terminal
- Import mode: importlib

## Key Patterns for Development

### Adding New Configuration Fields

Extend the `Settings` class in `tools/config/settings.py`:

```python
class Settings(BaseSettings):
    # Existing fields...

    # Add your new fields
    NEW_SETTING: str = "default_value"
    ANOTHER_SETTING: int = 42
```

Then add to `.env.local`:
```bash
NEW_SETTING=custom_value
ANOTHER_SETTING=100
```

### Adding New Logger Formatters

Create a new formatter in `tools/logger/`:
1. Extend `logging.Formatter`
2. Export from `tools/logger/__init__.py`
3. Update `Logger.__init__()` to support the new type

### Testing Utilities

When testing the utilities themselves:
- Logger: Capture logs using `assertLogs` context manager
- Config: Use Pydantic's model instantiation with kwargs to override values
- Timer: Check debug logs for execution time messages

## CI/CD Workflows

GitHub Actions workflows in `.github/workflows/`:
- **actionlint.yml**: Lint GitHub Actions workflows
- **docker.yml**: Validate Docker build
- **devcontainer.yml**: Validate Dev Container configuration
- **format.yml**: Check Ruff formatting
- **lint.yml**: Run Ruff + ty linting
- **test.yml**: Run pytest with coverage
- **publish-app.yml**: Publish app image to GHCR
- **publish-devcontainer.yml**: Publish dev container image to GHCR
- **release.yml**: Draft and publish releases

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
