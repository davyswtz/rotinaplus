# RotinaPlus

Monorepo do projeto **RotinaPlus**, contendo backend API, app iOS nativo e app Android.

## Estrutura

```
rotinaplus/
├── backend/          # API REST em Laravel (PHP)
├── ios/              # App iOS nativo em Swift (MVVM)
├── mobile-android/   # App Android em React Native (TypeScript)
├── docs/             # Documentação do projeto
└── .github/workflows/ # CI/CD
```

## Projetos

| Projeto | Stack | Documentação |
|---------|-------|--------------|
| [backend](./backend/) | Laravel 11, PHP 8.2+ | [backend/README.md](./backend/README.md) |
| [ios](./ios/) | Swift, SwiftUI, MVVM | [ios/README.md](./ios/README.md) |
| [mobile-android](./mobile-android/) | React Native, TypeScript | [mobile-android/README.md](./mobile-android/README.md) |

## Documentação geral

- [Infraestrutura](./docs/infraestrutura.md)
- [API](./docs/api.md)
- [Arquitetura](./docs/arquitetura.md)

## API Base URL

```
http://181.215.135.114
```
