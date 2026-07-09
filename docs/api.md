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

### Rotinas

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/rotinas` | Lista todas as rotinas |
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

## Implementação

O formato de erro é tratado em `backend/app/Exceptions/ApiExceptionHandler.php` e registrado em `bootstrap/app.php`.
