import React, { useEffect, useState } from 'react';
import { AppNavigator } from './src/navigation/AppNavigator';
import { LoadingScreen } from './src/screens/LoadingScreen';
import { useAuthStore } from './src/store/authStore';

const SPLASH_MS = 2200;

function App(): React.JSX.Element {
  const hydrate = useAuthStore((state) => state.hydrate);
  const isHydrated = useAuthStore((state) => state.isHydrated);
  const [mostrarSplash, setMostrarSplash] = useState(true);

  useEffect(() => {
    void hydrate();
  }, [hydrate]);

  useEffect(() => {
    const timer = setTimeout(() => setMostrarSplash(false), SPLASH_MS);
    return () => clearTimeout(timer);
  }, []);

  if (mostrarSplash || !isHydrated) {
    return <LoadingScreen />;
  }

  return <AppNavigator />;
}

export default App;
