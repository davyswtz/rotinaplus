import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useNavigation } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { cores } from '../theme/colors';
import { RootStackParamList } from '../navigation/AppNavigator';

const TOTAL_PAGINAS = 3;
/** Página 2 de 3 no onboarding (índice 1). */
const PAGINA_ATUAL = 1;

type Nav = NativeStackNavigationProp<RootStackParamList, 'CriePersonagem'>;

// MARK: - Intro "Crie seu personagem" (após Welcome)
// Espelha TelaCriePersonagem.swift no iOS. Usa a pata, sem a raposa do mock.

export function CriePersonagemScreen() {
  const navigation = useNavigation<Nav>();

  const concluir = () => {
    navigation.replace('Home');
  };

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <View style={styles.conteudo}>
        <View style={styles.espacador} />

        <Text style={styles.mascote}>🐾</Text>

        <Text style={styles.titulo}>Crie seu personagem único</Text>

        <Text style={styles.descricao}>
          Escolha sua classe, avatar e nome. Seu herói evolui conforme você
          avança na vida real.
        </Text>

        <View style={styles.espacador} />

        <View style={styles.indicador}>
          {Array.from({ length: TOTAL_PAGINAS }, (_, indice) =>
            indice === PAGINA_ATUAL ? (
              <View key={indice} style={styles.indicadorAtivo} />
            ) : (
              <View key={indice} style={styles.indicadorInativo} />
            ),
          )}
        </View>

        <TouchableOpacity
          style={styles.botaoProximo}
          onPress={concluir}
          activeOpacity={0.85}
        >
          <Text style={styles.textoBotaoProximo}>Próximo →</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.botaoPular}
          onPress={concluir}
          activeOpacity={0.7}
        >
          <Text style={styles.textoBotaoPular}>Pular</Text>
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
  fundo: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: cores.fundoTela,
  },
  conteudo: {
    flex: 1,
    paddingHorizontal: 24,
    paddingBottom: 16,
  },
  espacador: {
    flex: 1,
  },
  mascote: {
    fontSize: 88,
    textAlign: 'center',
    marginBottom: 40,
  },
  titulo: {
    fontSize: 28,
    fontWeight: 'bold',
    color: cores.textoPrimario,
    textAlign: 'center',
    marginBottom: 16,
  },
  descricao: {
    fontSize: 16,
    color: cores.textoSecundario,
    textAlign: 'center',
    lineHeight: 24,
    paddingHorizontal: 8,
  },
  indicador: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 8,
    marginBottom: 28,
  },
  indicadorAtivo: {
    width: 24,
    height: 8,
    borderRadius: 4,
    backgroundColor: cores.roxoPrimario,
  },
  indicadorInativo: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.25)',
  },
  botaoProximo: {
    backgroundColor: cores.roxoPrimario,
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: 'center',
    marginBottom: 8,
  },
  textoBotaoProximo: {
    color: cores.textoPrimario,
    fontSize: 16,
    fontWeight: '600',
  },
  botaoPular: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  textoBotaoPular: {
    color: 'rgba(255, 255, 255, 0.55)',
    fontSize: 15,
  },
});
