import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LoginScreen } from '../screens/LoginScreen';
import { useAuthStore } from '../store/authStore';
import { cores } from '../theme/colors';

export type RootStackParamList = {
  Login: undefined;
  Home: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

function HomeScreen() {
  const logout = useAuthStore((state) => state.logout);

  return (
    <View style={styles.home}>
      <Text style={styles.homeTitle}>RotinaPlus</Text>
      <Text style={styles.homeSubtitle}>Login realizado com sucesso.</Text>
      <TouchableOpacity style={styles.logoutButton} onPress={() => void logout()}>
        <Text style={styles.logoutText}>Sair</Text>
      </TouchableOpacity>
    </View>
  );
}

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
        initialRouteName={isAuthenticated ? 'Home' : 'Login'}
        screenOptions={{ headerShown: false }}
      >
        {isAuthenticated ? (
          <Stack.Screen name="Home" component={HomeScreen} />
        ) : (
          <Stack.Screen name="Login" component={LoginScreen} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  home: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: cores.fundoTela,
    paddingHorizontal: 24,
  },
  homeTitle: {
    color: cores.textoPrimario,
    fontSize: 26,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  homeSubtitle: {
    color: cores.textoSecundario,
    fontSize: 15,
    textAlign: 'center',
  },
  logoutButton: {
    marginTop: 24,
    backgroundColor: cores.roxoPrimario,
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 12,
  },
  logoutText: {
    color: cores.textoPrimario,
    fontSize: 15,
    fontWeight: '600',
  },
});
