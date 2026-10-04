#!/bin/sh
set -e

cd /var/www/html

if [ ! -f vendor/autoload.php ]; then
    composer install --no-interaction --prefer-dist
fi

# Chave só para desenvolvimento; se não vier do ambiente, gera uma nova.
if [ -z "$APP_KEY" ]; then
    export APP_KEY="$(php artisan key:generate --show)"
fi

if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Aguardando o banco em ${DB_HOST}:${DB_PORT}..."
    i=0
    until php -r '
        try {
            new PDO("pgsql:host=".getenv("DB_HOST").";port=".getenv("DB_PORT").";dbname=".getenv("DB_DATABASE"), getenv("DB_USERNAME"), getenv("DB_PASSWORD"));
        } catch (Throwable $e) { fwrite(STDERR, $e->getMessage()."\n"); exit(1); }
    ' 2>/dev/null; do
        i=$((i + 1))
        if [ "$i" -ge 30 ]; then
            echo "Não foi possível conectar ao banco. Confira o Tailscale e o .env." >&2
            exit 1
        fi
        sleep 2
    done
    php artisan migrate --force
fi

exec "$@"
