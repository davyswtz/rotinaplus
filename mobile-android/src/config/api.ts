import { Platform } from 'react-native';

/** Produção (VPS) — banco e usuários reais do Rotina Plus. */
export const PRODUCTION_API_URL = 'http://181.215.135.114';

/** Backend local via Docker. Emulador Android usa 10.0.2.2 → host. */
const DEV_API_HOST = Platform.OS === 'android' ? '10.0.2.2' : '127.0.0.1';
export const DEVELOPMENT_API_URL = `http://${DEV_API_HOST}:8000`;

/**
 * `true` = usa a API/banco da VPS mesmo em __DEV__ (login com contas cadastradas).
 * `false` = usa o backend local Docker.
 */
export const USE_REMOTE_API = true;

export const API_BASE_URL =
  !__DEV__ || USE_REMOTE_API ? PRODUCTION_API_URL : DEVELOPMENT_API_URL;
