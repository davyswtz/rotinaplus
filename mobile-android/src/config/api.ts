import { Platform } from 'react-native';

export const PRODUCTION_API_URL = 'http://181.215.135.114';

const DEV_API_HOST = Platform.OS === 'android' ? '10.0.2.2' : '127.0.0.1';
export const DEVELOPMENT_API_URL = `http://${DEV_API_HOST}:8000`;

export const API_BASE_URL = __DEV__ ? DEVELOPMENT_API_URL : PRODUCTION_API_URL;
