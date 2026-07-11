import AsyncStorage from '@react-native-async-storage/async-storage';

const TOKEN_KEY = 'auth_token';

let cachedToken: string | null = null;

export async function hydrateToken(): Promise<string | null> {
  cachedToken = await AsyncStorage.getItem(TOKEN_KEY);
  return cachedToken;
}

export function getToken(): string | null {
  return cachedToken;
}

export async function saveToken(token: string): Promise<void> {
  cachedToken = token;
  await AsyncStorage.setItem(TOKEN_KEY, token);
}

export async function clearToken(): Promise<void> {
  cachedToken = null;
  await AsyncStorage.removeItem(TOKEN_KEY);
}
