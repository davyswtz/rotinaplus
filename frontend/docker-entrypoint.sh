#!/bin/sh
set -e

cd /app

if [ ! -d node_modules/.bin ]; then
    npm ci
fi

exec "$@"
