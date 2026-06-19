FROM python:3.14.4-slim
ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    TZ=UTC

# Cache-bust for the apt layer below. Bump this value (date) before tagging a new
# base release so Docker Hub build caching cannot reuse a stale `apt upgrade` layer
# and the image actually picks up the latest Debian security patches.
ARG APT_BUST=2026-06-19

# Install all system dependencies in a single layer:
# Build-time (gcc, *-dev — removed after poetry install in main Dockerfile)
# Runtime (gettext, postgresql-client, logrotate, libgl1, rsync, etc.)
RUN echo "apt-bust: ${APT_BUST}" \
    && apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
        gcc \
        gettext \
        libpq-dev \
        libgeos-dev \
        libgdal-dev \
        libmagic-dev \
        zlib1g zlib1g-dev \
        libcairo2-dev pkg-config \
        postgresql-client \
        logrotate \
        libgl1 \
        util-linux \
        rsync \
        git \
        mc \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip "wheel>=0.46.2"

# install poetry (2.x required for CVE-2026-34591 fix)
RUN pip install poetry==2.3.4

# Create non-root user for security
RUN groupadd -r django_group && useradd -r -g django_group -m -d /home/django_user django_user \
    && mkdir -p /home/django_user/.config/mc \
    && chown -R django_user:django_group /home/django_user

WORKDIR /app

RUN poetry config virtualenvs.create false
