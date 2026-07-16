#!/usr/bin/env bash
set -euo pipefail

# Deploy do backend Laravel no servidor de produção (Docker).
# Caminho no servidor: ~/projetos/rotinaplus

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"

cd "$ROOT_DIR"

echo "==> Atualizando código..."
git fetch origin
git checkout main
git pull --ff-only origin main

cd "$BACKEND_DIR"

echo "==> Subindo containers..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

echo "==> Instalando dependências PHP..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T app composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

echo "==> Rodando migrations..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T app php artisan migrate --force

echo "==> Criando usuário de teste (sem dados fictícios)..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T app php artisan db:seed --class=TestUserSeeder --force

echo "==> Otimizando cache..."
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T app php artisan config:cache
sudo docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T app php artisan route:cache

echo ""
echo "Deploy concluído!"
echo "  API: http://181.215.135.114/api/v1"
