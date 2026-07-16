# iOS — RotinaPlus

App iOS nativo em **Swift** com arquitetura **MVVM**.

## Estrutura

```
RotinaPlus/
├── App/              # Entry point e AppDelegate
├── Models/           # Structs de dados
├── ViewModels/       # Lógica de apresentação (ObservableObject)
├── Views/
│   ├── Screens/      # Telas completas
│   └── Components/   # Componentes reutilizáveis
├── Services/
│   ├── Networking/   # APIClient, Endpoints
│   └── Auth/         # AuthManager
├── Utils/
└── Resources/        # Localizable.strings, assets
```

## Setup

O projeto Xcode já foi gerado com **XcodeGen**. Para regenerar após mudanças em `project.yml`:

```bash
cd ios
xcodegen generate
open RotinaPlus.xcodeproj
```

Se preferir criar manualmente no Xcode, os arquivos Swift estão em `ios/RotinaPlus/`.

## API Base URL

- **Debug (Xcode / simulador):** `http://127.0.0.1:8000` — backend local Docker
- **Release:** `http://181.215.135.114` — VPS

Suba o backend local antes de rodar o app:

```bash
cd backend
docker compose up -d
```

API: `http://127.0.0.1:8000/api/v1`

## Arquitetura MVVM

```
View → ViewModel → Service → APIClient
```
