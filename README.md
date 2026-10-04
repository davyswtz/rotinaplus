# Rotina Plus

Aplicativo pessoal para organizar a semana: tarefas do dia a dia, hábitos, humor, consumo de água, metas, finanças e um diário de reflexão — tudo em um só lugar.

No desktop (telas ≥ 1024px), a tela inicial vira um **caderno digital de duas folhas**: a esquerda com a semana (tarefas por dia + anotações livres), a direita com um quadro de widgets arrastáveis e redimensionáveis (hábitos, água, humor, progresso, metas, reflexão) e uma camada de desenho por cima (linhas, formas, texto). No mobile, o app usa uma navegação simples em abas, mobile-first.

## Stack

- **Backend**: PHP 8.3 + Laravel 13, autenticação via Laravel Sanctum (token), banco SQLite/MySQL.
- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS, React Router, Axios.

## Funcionalidades

- **Autenticação**: registro e login por e-mail/senha.
- **Semana**: tarefas de rotina por dia, com progresso semanal.
- **Hábitos**: quadro semanal de hábitos marcáveis por dia.
- **Humor**: registro diário de humor (5 níveis).
- **Água**: contador de consumo diário.
- **Metas**: lista de objetivos com conclusão.
- **Financeiro**: lançamento de receitas e despesas, com resumo mensal.
- **Diário**: reflexão livre por semana.
- **Caderno desktop**: visão de duas folhas com papel quadriculado, fonte manuscrita, widgets arrastáveis/redimensionáveis (adicionados/removidos por um painel próprio), camada de desenho (linhas, formas geométricas, texto com quebra de linha, paleta de cores, desfazer/refazer) e um cadeado para travar a edição do layout.
- **Tema claro/escuro** com preto real no modo escuro.

## Estrutura do projeto

```
rotinaplus/
├── backend/    # API Laravel
└── frontend/   # SPA React (Vite)
```

## Rodando com Docker (recomendado)

Pré-requisitos: [Docker](https://docs.docker.com/get-docker/) com Compose e o [Tailscale](https://tailscale.com/download) ligado e com acesso ao servidor de banco compartilhado.

```bash
cp .env.example .env     # preencha DB_USERNAME e DB_PASSWORD com os dados que você recebeu
docker compose up --build
```

- Frontend: `http://localhost:5173`
- API: `http://localhost:8000/api`

Observações:

- O `.env` **não** é versionado. Cada pessoa usa o seu próprio usuário do banco.
- As migrations só rodam com `RUN_MIGRATIONS=true`; deixe `false`, a menos que você seja o dono do banco.
- Sem Tailscale ou offline, use um Postgres local: no `.env` defina `DB_HOST=db`, `DB_USERNAME`, `DB_PASSWORD` e `RUN_MIGRATIONS=true`, e rode `docker compose --profile local up --build`.
- Para parar: `docker compose down`.

## Rodando o projeto (sem Docker)

### Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

A API sobe em `http://127.0.0.1:8000`.

### Frontend

```bash
cd frontend
npm install
cp .env.example .env   # aponte VITE_API_URL para a URL do backend
npm run dev
```

O app sobe em `http://localhost:5173`.

## Principais rotas da API

Todas as rotas (exceto registro/login) exigem token Sanctum via header `Authorization: Bearer <token>`.

| Recurso | Rotas |
| --- | --- |
| Autenticação | `POST /registro`, `POST /login`, `POST /logout`, `GET /usuario` |
| Tarefas | `GET/POST /tarefas`, `PUT/DELETE /tarefas/{id}`, `PATCH /tarefas/{id}/concluir` |
| Hábitos | `GET/POST /habitos`, `PUT/DELETE /habitos/{id}`, `PATCH /habitos/{id}/registrar-dia` |
| Metas | `GET/POST /metas`, `PUT/DELETE /metas/{id}`, `PATCH /metas/{id}/concluir` |
| Humor | `GET /humor`, `POST /humor` |
| Água | `GET /agua`, `POST /agua/adicionar`, `POST /agua/remover` |
| Reflexão | `GET /reflexao`, `POST /reflexao` |
| Financeiro | `GET/POST /transacoes`, `PUT/DELETE /transacoes/{id}` |
| Categorias | `GET/POST /categorias`, `PUT/DELETE /categorias/{id}` |

## Testando a API

O arquivo [`insomnia_rotina_plus.json`](./insomnia_rotina_plus.json) na raiz do projeto pode ser importado direto no [Insomnia](https://insomnia.rest/) com todas as rotas já configuradas.
