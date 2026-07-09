#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v docker >/dev/null 2>&1; then
  echo "Erro: Docker não encontrado. Instale o Docker Desktop: https://www.docker.com/products/docker-desktop/"
  exit 1
fi

echo "==> Subindo containers..."
docker compose up -d --build

echo "==> Instalando dependências PHP (dentro do container)..."
docker compose exec -T app composer install --no-interaction --prefer-dist --optimize-autoloader

echo "==> Gerando APP_KEY (se necessário)..."
docker compose exec -T app php artisan key:generate --force

echo "==> Rodando migrations..."
docker compose exec -T app php artisan migrate --force

echo "==> Otimizando cache..."
docker compose exec -T app php artisan config:cache
docker compose exec -T app php artisan route:cache

echo ""
echo "Pronto!"
echo "  API:     http://localhost:8000"
echo "  Adminer: http://localhost:8080"
echo ""
echo "Testar: curl http://localhost:8000/api/v1/rotinas"
