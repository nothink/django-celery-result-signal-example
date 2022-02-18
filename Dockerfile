FROM --platform=amd64 python:3.10.2-slim-bullseye as base

RUN --mount=type=cache,target=/var/cache \
    apt-get update \
 && apt-get install -y libmariadb-dev

COPY . /app
WORKDIR /app
EXPOSE 8000

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools \
 && pip install poetry \
 && poetry config virtualenvs.create false \
 && poetry config experimental.new-installer false \
 && poetry install --no-root --no-interaction --no-ansi

FROM base as django

CMD python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000

FROM base as celery

CMD celery -A tasks worker --loglevel=INFO
