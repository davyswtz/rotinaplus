#!/usr/bin/env bash
set -euo pipefail

# Deploy remoto: conecta no servidor e executa deploy-backend.sh
# Uso: bash scripts/deploy-remote.sh

SERVER_HOST="181.215.135.114"
SERVER_PORT="2222"
SERVER_USER="deploy"
REMOTE_DIR="${REMOTE_DIR:-~/projetos/rotinaplus}"

echo "==> Conectando em ${SERVER_USER}@${SERVER_HOST}:${SERVER_PORT}..."
ssh -p "$SERVER_PORT" "${SERVER_USER}@${SERVER_HOST}" \
  "cd ${REMOTE_DIR} && bash scripts/deploy-backend.sh"
