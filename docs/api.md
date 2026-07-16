# API — RotinaPlus

## Base URL

```
http://181.215.135.114/api/v1
```

## Padrão de resposta de sucesso

```json
{
  "success": true,
  "data": { }
}
```

Respostas com coleção usam `data` como array. Mensagens opcionais vêm no campo `message`.

## Padrão de resposta de erro

Todas as respostas de erro da API seguem este formato:

```json
{
  "success": false,
  "message": "Descrição do erro",
  "errors": {
    "campo": ["mensagem de validação"]
  }
}
```

### Campos

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `success` | boolean | Sempre `false` em erros |
| `message` | string | Mensagem legível do erro |
| `errors` | object | Detalhes por campo (vazio `{}` quando não há erros de validação) |

### Exemplos

**Validação (422):**

```json
{
  "success": false,
  "message": "Erro de validação.",
  "errors": {
    "titulo": ["O campo titulo é obrigatório."]
  }
}
```

**Não encontrado (404):**

```json
{
  "success": false,
  "message": "Recurso não encontrado.",
  "errors": {}
}
```

**Não autenticado (401):**

```json
{
  "success": false,
  "message": "Não autenticado.",
  "errors": {}
}
```

## Endpoints

> Rotas autenticadas exigem header `Authorization: Bearer {token}`.

### Auth

| Método | Endpoint | Auth | Descrição |
|--------|----------|------|-----------|
| POST | `/auth/login` | Não | Login email/senha → `{ user, perfil, token }` |
| POST | `/auth/social` | Não | Login social |

### Perfil / Dashboard

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/me` | Usuário + perfil do herói |
| PUT | `/perfil` | Atualiza nome_heroi, avatar_key, classe |
| GET | `/dashboard` | Home: perfil, missões do dia, XP, badge notificações, resumo academia |

### Missões

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/missoes` | Missões do dia (hoje) |
| PATCH | `/missoes/{id}/toggle` | Conclui / reabre missão (+/- XP no perfil) |

### Notificações

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/notificacoes` | Lista notificações |
| PATCH | `/notificacoes/{id}/lida` | Marca uma como lida |
| POST | `/notificacoes/ler-todas` | Marca todas como lidas |

### Academia

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/academia` | Stats, dias da semana, volumes, treino de hoje |
| PATCH | `/academia/dias/{id}/toggle` | Marca/desmarca dia como feito |

### Rotinas

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/rotinas` | Lista rotinas do usuário autenticado |
| POST | `/rotinas` | Cria uma rotina |
| GET | `/rotinas/{id}` | Exibe uma rotina |
| PUT | `/rotinas/{id}` | Atualiza uma rotina |
| DELETE | `/rotinas/{id}` | Remove uma rotina |

#### POST /rotinas — Body

```json
{
  "titulo": "Academia",
  "descricao": "Treino de pernas",
  "concluida": false
}
```

#### Resposta de sucesso (201)

```json
{
  "success": true,
  "message": "Rotina criada com sucesso.",
  "data": {
    "id": 1,
    "titulo": "Academia",
    "descricao": "Treino de pernas",
    "concluida": false,
    "created_at": "2026-07-09T00:00:00.000000Z",
    "updated_at": "2026-07-09T00:00:00.000000Z"
  }
}
```

## Tabelas (domínio gamificação)

| Tabela | Uso |
|--------|-----|
| `perfis` | Herói: avatar, classe, nível, XP, moedas, streak |
| `missoes` | Missões do dia por usuário/data |
| `notificacoes` | Inbox do usuário |
| `academia_configs` | Meta semanal + sequência de treinos |
| `academia_dias` | Cápsulas da semana (Seg–Dom) |
| `academia_volumes` | Volume semanal (kg) |
| `academia_treinos` | Treino de hoje / biblioteca |

Seed demo: `php artisan db:seed` (usuário `davy@teste.com` / `senha123`).

## Implementação

O formato de erro é tratado em `backend/app/Exceptions/ApiExceptionHandler.php` e registrado em `bootstrap/app.php`.
