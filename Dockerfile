ARG UV_VERSION=latest
ARG VARIANT=3.14


FROM ghcr.io/astral-sh/uv:$UV_VERSION AS uv


FROM python:$VARIANT-slim

WORKDIR /app

COPY --from=uv /uv /uvx /bin/
COPY pyproject.toml uv.lock ./

ENV PYTHONDONTWRITEBYTECODE=True \
    PYTHONUNBUFFERED=True \
    UV_LINK_MODE=copy

RUN uv sync --frozen --no-install-project
