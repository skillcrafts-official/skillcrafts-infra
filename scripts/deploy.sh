#!/bin/bash
set -e # Прерывать выполнение при любой ошибке

# --- Переменные окружения ---
DOMAIN="example.com"
REPO_URL="git@github.com:yourusername/nginx-config.git"
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

echo ">>> Шаг 1: Установка Nginx..."
sudo apt update && sudo apt install -y nginx

echo ">>> Шаг 2: Настройка фаервола..."
sudo ufw allow 'Nginx Full' # Открывает порты 80 и 443
sudo ufw --force enable

echo ">>> Шаг 3: Клонирование конфигураций из Git..."
cd /tmp && git clone $REPO_URL nginx-config
sudo cp -r nginx-config/sites-available/* $SITES_AVAILABLE/
# Создание символьных ссылок
sudo ln -sf $SITES_AVAILABLE/$DOMAIN $SITES_ENABLED/$DOMAIN
rm -rf nginx-config

echo ">>> Шаг 4: Получение SSL-сертификата..."
sudo apt install -y certbot python3-certbot-nginx
# --non-interactive позволяет избежать ручного ввода
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email your@email.com --redirect

echo ">>> Шаг 5: Проверка конфигурации и перезапуск Nginx..."
sudo nginx -t && sudo systemctl reload nginx