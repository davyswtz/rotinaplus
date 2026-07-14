import React, { useEffect, useRef } from 'react';
import {
  Animated,
  Easing,
  Image,
  StyleSheet,
  Text,
  View,
} from 'react-native';

/** Splash / loading — espelha TelaLoading.swift (mascote + patinha + pontos). */
export function LoadingScreen() {
  const patinha = useRef(new Animated.Value(0)).current;
  const ponto0 = useRef(new Animated.Value(0)).current;
  const ponto1 = useRef(new Animated.Value(0)).current;
  const ponto2 = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const pulse = Animated.loop(
      Animated.sequence([
        Animated.timing(patinha, {
          toValue: 1,
          duration: 700,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(patinha, {
          toValue: 0,
          duration: 700,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]),
    );

    const bounce = (valor: Animated.Value, delay: number) =>
      Animated.loop(
        Animated.sequence([
          Animated.delay(delay),
          Animated.timing(valor, {
            toValue: 1,
            duration: 450,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(valor, {
            toValue: 0,
            duration: 450,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]),
      );

    pulse.start();
    const b0 = bounce(ponto0, 0);
    const b1 = bounce(ponto1, 150);
    const b2 = bounce(ponto2, 300);
    b0.start();
    b1.start();
    b2.start();

    return () => {
      pulse.stop();
      b0.stop();
      b1.stop();
      b2.stop();
    };
  }, [patinha, ponto0, ponto1, ponto2]);

  const patinhaScale = patinha.interpolate({
    inputRange: [0, 1],
    outputRange: [0.92, 1.15],
  });
  const patinhaOpacity = patinha.interpolate({
    inputRange: [0, 1],
    outputRange: [0.7, 1],
  });

  const pontoAnim = (valor: Animated.Value) => ({
    transform: [
      {
        translateY: valor.interpolate({
          inputRange: [0, 1],
          outputRange: [5, -5],
        }),
      },
    ],
    opacity: valor.interpolate({
      inputRange: [0, 1],
      outputRange: [0.45, 1],
    }),
  });

  return (
    <View style={styles.container}>
      <View style={styles.conteudo}>
        <Image
          source={require('../assets/splash_guara.png')}
          style={styles.mascote}
          resizeMode="contain"
        />

        <Text style={styles.titulo}>
          <Text style={styles.tituloRotina}>Rotina </Text>
          <Text style={styles.tituloPlus}>Plus</Text>
        </Text>

        <Text style={styles.tagline}>GAMIFIQUE SUA VIDA REAL</Text>

        <View style={styles.indicador}>
          <Animated.Text
            style={[
              styles.patinha,
              { opacity: patinhaOpacity, transform: [{ scale: patinhaScale }] },
            ]}
          >
            🐾
          </Animated.Text>
          <View style={styles.pontos}>
            {[ponto0, ponto1, ponto2].map((valor, indice) => (
              <Animated.View
                key={indice}
                style={[styles.ponto, pontoAnim(valor)]}
              />
            ))}
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0D0817',
  },
  conteudo: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  mascote: {
    width: 160,
    height: 160,
    marginBottom: 28,
  },
  titulo: {
    fontSize: 34,
    fontWeight: '700',
    marginBottom: 10,
  },
  tituloRotina: {
    color: '#AB7EFF',
  },
  tituloPlus: {
    color: '#49E8A7',
  },
  tagline: {
    fontSize: 12,
    fontWeight: '500',
    letterSpacing: 1.5,
    color: 'rgba(255,255,255,0.40)',
    fontVariant: ['tabular-nums'],
    marginBottom: 36,
  },
  indicador: {
    alignItems: 'center',
    gap: 14,
  },
  patinha: {
    fontSize: 28,
  },
  pontos: {
    flexDirection: 'row',
    gap: 10,
  },
  ponto: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#9E73F2',
  },
});
