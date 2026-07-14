import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LoginScreen } from '../screens/LoginScreen';
import { WelcomeScreen } from '../screens/WelcomeScreen';
import { EscolhaAvatarScreen } from '../screens/EscolhaAvatarScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { useAuthStore } from '../store/authStore';

export type RootStackParamList = {
  Login: undefined;
  Welcome: undefined;
  EscolhaAvatar: undefined;
  Home: undefined;
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
            <Stack.Screen name="EscolhaAvatar" component={EscolhaAvatarScreen} />
            <Stack.Screen name="Home" component={HomeScreen} />
          </>
        ) : (
          <Stack.Screen name="Login" component={LoginScreen} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
