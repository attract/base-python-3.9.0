FROM python:3.9.17-slim-buster
ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    TZ=UTC

ARG SERVER_TYPE
ARG RUN_TESTS

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends \
        gcc \
        gettext \
        postgresql-server-dev-all \
        libgeos-dev \
        libgdal-dev \
        libmagic-dev \
        zlib1g zlib1g-dev \
        postgresql-client \
        git \
        mc \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-use-pep517 --upgrade pip

# install poetry
RUN pip install poetry==1.3.2

