import React, { useEffect, useState } from 'react';
import { AppNavigator } from './src/navigation/AppNavigator';
import { LoadingScreen } from './src/screens/LoadingScreen';
import { useAuthStore } from './src/store/authStore';
import { installOfflineSync } from './src/offline/sync';
import { startOfflineRuntime } from './src/offline/store';
import { iniciarLembretes } from './src/offline/lembretes';

const SPLASH_MS = 2200;

function App(): React.JSX.Element {
  const hydrate = useAuthStore((state) => state.hydrate);
  const isHydrated = useAuthStore((state) => state.isHydrated);
  const [mostrarSplash, setMostrarSplash] = useState(true);

  useEffect(() => {
    installOfflineSync();
    const stop = startOfflineRuntime();
    void hydrate();
    void iniciarLembretes();
    return stop;
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
