# Backend — RotinaPlus API

API REST em **Laravel** com arquitetura em camadas.

## Arquitetura

```
Controller (Api/) → Service → Repository → Model
                      ↓
                    DTO
```

| Camada | Responsabilidade |
|--------|------------------|
| `Http/Controllers/Api/` | Orquestra requisições HTTP |
| `Http/Requests/` | Validação de entrada |
| `Http/Resources/` | Formatação de respostas JSON |
| `Services/` | Regras de negócio |
| `Repositories/` | Acesso a dados (abstrai Eloquent) |
| `DTOs/` | Transferência de dados entre camadas |
| `Models/` | Entidades Eloquent |

## Exemplo de referência: Rotina

Recurso completo implementado em todas as camadas. Use como modelo ao criar novos recursos.

**Rotas** (`routes/api.php`):

| Método | Rota | Ação |
|--------|------|------|
| GET | `/api/v1/rotinas` | Listar |
| POST | `/api/v1/rotinas` | Criar |
| GET | `/api/v1/rotinas/{id}` | Exibir |
| PUT/PATCH | `/api/v1/rotinas/{id}` | Atualizar |
| DELETE | `/api/v1/rotinas/{id}` | Remover |

## Setup local

### Com Docker (recomendado)

**Pré-requisitos:** Docker Desktop instalado e **em execução**.

```bash
cd backend
./docker-setup.sh
```

Equivalente manual (não precisa do Composer instalado na máquina):

```bash
docker compose up -d --build
docker compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader
docker compose exec app php artisan key:generate --force
docker compose exec app php artisan migrate --force
```

A API ficará disponível em `http://localhost:8000`.

Serviços:
| Serviço | URL |
|---------|-----|
| API (Nginx) | http://localhost:8000 |
| Adminer (MySQL) | http://localhost:8080 |
| MySQL | localhost:3306 |
| Redis | localhost:6379 |

### Sem Docker

```bash
composer install
cp .env.example .env
# Ajuste DB_HOST=127.0.0.1 e REDIS_HOST=127.0.0.1
php artisan key:generate
php artisan migrate
php artisan serve
```

> **Nota:** Dentro do Docker, use `DB_HOST=mysql` e `REDIS_HOST=redis` (nomes dos serviços). Fora do Docker, use `127.0.0.1`.

## Testes

```bash
php artisan test
```

## Documentação da API

Veja [docs/api.md](../docs/api.md) na raiz do monorepo.
