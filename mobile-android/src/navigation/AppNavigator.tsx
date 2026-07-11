import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
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
  return (
    <View style={styles.home}>
      <Text style={styles.homeTitle}>RotinaPlus</Text>
      <Text style={styles.homeSubtitle}>Login realizado com sucesso.</Text>
    </View>
  );
}

export function AppNavigator() {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

  return (
    <NavigationContainer>
      <Stack.Navigator
        key={isAuthenticated ? 'authenticated' : 'guest'}
        initialRouteName={isAuthenticated ? 'Home' : 'Login'}
        screenOptions={{ headerShown: false }}
      >
        {!isAuthenticated ? (
          <Stack.Screen name="Login" component={LoginScreen} />
        ) : (
          <Stack.Screen name="Home" component={HomeScreen} />
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
});
