import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { cores } from '../theme/colors';
import { useAuthStore } from '../store/authStore';

// MARK: - Home mínima (espelha HomeView.swift)
export function HomeScreen() {
  const logout = useAuthStore((state) => state.logout);

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.conteudo}>
        <Text style={styles.titulo}>RotinaPlus</Text>
        <Text style={styles.subtitulo}>Login realizado com sucesso.</Text>
        <TouchableOpacity style={styles.botao} onPress={logout} activeOpacity={0.85}>
          <Text style={styles.textoBotao}>Sair</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  areaSegura: {
    flex: 1,
    backgroundColor: cores.fundoTela,
  },
  conteudo: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
    gap: 16,
  },
  titulo: {
    fontSize: 34,
    fontWeight: 'bold',
    color: cores.textoPrimario,
  },
  subtitulo: {
    fontSize: 15,
    color: cores.textoSecundario,
  },
  botao: {
    marginTop: 8,
    backgroundColor: cores.roxoPrimario,
    borderRadius: 12,
    paddingHorizontal: 24,
    paddingVertical: 12,
  },
  textoBotao: {
    color: cores.textoPrimario,
    fontWeight: '600',
    fontSize: 16,
  },
});
