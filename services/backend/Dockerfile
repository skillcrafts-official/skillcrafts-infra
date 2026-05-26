# Используем официальный образ с нужным языком/инструментами
FROM python:3.12-alpine

# Устанавливаем все переменные окружения
ENV APP_HOME=/app \
    SERVICE_HOME=/backend \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Аргумент для сборки – токен доступа к GitHub
ARG GITHUB_TOKEN
# Аргумент из docker-compose
ARG DEBUG
ARG CACHEBUST
# Переносим DEBUG в окружение, чтобы он был доступен во время работы контейнера
ENV DEBUG=${DEBUG}

# Загружаем зависимости
RUN apk update \
    && apk add --virtual .build-deps \
        git \
        postgresql-dev \
        gcc \
        python3-dev \
        musl-dev \
        libffi-dev \
    # Runtime зависимости (остаются)
    && apk add --no-cache \
        postgresql-libs \
        libpq \
        netcat-openbsd \
        su-exec

WORKDIR $APP_HOME

# Создаём рабочую директорию внутри контейнера, клонируем проект и устанавливаем WorkDir
RUN mkdir -p ${APP_HOME} \
    && git clone https://github.com/skillcrafts-official/skillcrafts-backend.git ${APP_HOME} \
    && apk del .build-deps

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Создаём непривилегированного пользователя для безопасности
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p ${APP_HOME}/staticfiles ${APP_HOME}/media &&\
    chown -R appuser:appgroup /app

# Копируем entrypoint-скрипт и даём права
COPY ${SERVICE_HOME}/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Не переключаемся на appuser – это сделает entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Указываем порт, который приложение будет слушать (чисто документация)
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 8000 || exit 1

# Команда запуска приложения
CMD python manage.py migrate \
    && python manage.py collectstatic --noinput \
    && if [ "$DEBUG" = "True" ]; then \
            exec python manage.py runserver 0.0.0.0:8000; \
        else \
            exec gunicorn --bind 0.0.0.0:8000 --workers 4 drf_blog_api.wsgi; \
        fi