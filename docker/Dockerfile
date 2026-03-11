FROM registry.access.redhat.com/ubi9/python-311:latest

USER root
RUN dnf install -y --nodocs git && dnf clean all

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

ENV UV_PYTHON_PREFERENCE=only-system
ENV PATH="/app/.venv/bin:$PATH"
ENV VIRTUAL_ENV="/app/.venv"

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN echo "3.11" > .python-version \
    && uv sync --frozen --python python3.11 \
    && uv cache clean \
    && find /app/.venv -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null; true

COPY prepare.py ./

ENV GIT_REPO=""
ENV GIT_REF=""

RUN mkdir /workspace && chown default:0 /workspace
RUN mkdir -p /opt/app-root/src/.cache && chown -R default:0 /opt/app-root/src/.cache

COPY docker/entrypoint.sh ./
RUN chmod +x /app/entrypoint.sh

USER default

ENTRYPOINT ["/app/entrypoint.sh"]
