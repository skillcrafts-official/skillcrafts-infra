#!/bin/sh
# for entrypoints.sh Предназанчено для настройки окружения
set -e

# Исправляем права на директориях, которые могут быть перекрыты томами
chown -R appuser:appgroup /app/staticfiles /app/media 2>/dev/null || true

# Запускаем CMD от имени appuser, сохраняя сигналы (exec)
exec su-exec appuser "$@"