import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LoginScreen } from '../screens/LoginScreen';
import { RegisterScreen } from '../screens/RegisterScreen';
import { WelcomeScreen } from '../screens/WelcomeScreen';
import { EscolhaClasseScreen } from '../screens/EscolhaClasseScreen';
import { EscolhaAvatarScreen } from '../screens/EscolhaAvatarScreen';
import { NomeHeroiScreen } from '../screens/NomeHeroiScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { NotificacoesScreen } from '../screens/NotificacoesScreen';
import { useAuthStore } from '../store/authStore';

export type RootStackParamList = {
  Login: undefined;
  Register: undefined;
  Welcome: undefined;
  EscolhaClasse: undefined;
  EscolhaAvatar: {
    classeKey: string;
    classeNome: string;
    emojiClasse: string;
  };
  NomeHeroi: {
    avatarId: string;
    classeKey: string;
    classeNome: string;
    emojiClasse: string;
  };
  Home: undefined;
  Notificacoes: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export function AppNavigator() {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  const isHydrated = useAuthStore((state) => state.isHydrated);

  if (!isHydrated) {
    return null;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        key={isAuthenticated ? 'authenticated' : 'guest'}
        initialRouteName={isAuthenticated ? 'Welcome' : 'Login'}
        screenOptions={{ headerShown: false }}
      >
        {isAuthenticated ? (
          <>
            <Stack.Screen name="Welcome" component={WelcomeScreen} />
            <Stack.Screen name="EscolhaClasse" component={EscolhaClasseScreen} />
            <Stack.Screen name="EscolhaAvatar" component={EscolhaAvatarScreen} />
            <Stack.Screen name="NomeHeroi" component={NomeHeroiScreen} />
            <Stack.Screen name="Home" component={HomeScreen} />
            <Stack.Screen name="Notificacoes" component={NotificacoesScreen} />
          </>
        ) : (
          <>
            <Stack.Screen name="Login" component={LoginScreen} />
            <Stack.Screen name="Register" component={RegisterScreen} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
