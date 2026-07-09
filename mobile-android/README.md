# Android — RotinaPlus

App Android em **React Native** com **TypeScript**.

## Estrutura

```
src/
├── screens/        # Telas
├── components/     # Componentes reutilizáveis
├── navigation/     # React Navigation
├── services/       # API e autenticação
├── hooks/          # Custom hooks
├── store/          # Estado global (Zustand)
├── types/          # Tipos TypeScript
└── utils/          # Utilitários
```

## Setup

```bash
npm install
npm start          # Metro bundler
npm run android    # emulador/dispositivo Android conectado
npm run typecheck  # verificação TypeScript
```

O projeto nativo Android (`android/`) foi gerado via React Native 0.79.

## API Base URL

```
http://181.215.135.114
```

## Arquitetura

```
Screen → Hook/Store → Service → API (axios)
```
