import React, { useMemo, useState } from 'react';
import {
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useNavigation } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { cores } from '../theme/colors';
import { RootStackParamList } from '../navigation/AppNavigator';
import { CLASSES_HEROI, ClasseHeroi } from '../data/classes';

type Nav = NativeStackNavigationProp<RootStackParamList, 'EscolhaClasse'>;

/** Passo 1 de 3 — espelha TelaEscolhaClasse.swift / mock. */
export function EscolhaClasseScreen() {
  const navigation = useNavigation<Nav>();
  const [selecionada, setSelecionada] = useState<ClasseHeroi>(CLASSES_HEROI[0]);

  const cards = useMemo(() => CLASSES_HEROI, []);

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <View style={styles.conteudo}>
        <View style={styles.barraProgresso}>
          <View style={[styles.segmento, styles.segmentoAtivo]} />
          <View style={styles.segmento} />
          <View style={styles.segmento} />
        </View>

        <Text style={styles.passo}>PASSO 1 DE 3</Text>
        <Text style={styles.titulo}>Escolha sua classe</Text>
        <Text style={styles.subtitulo}>
          Define seus bônus iniciais e estilo de jogo
        </Text>

        <ScrollView
          style={styles.lista}
          contentContainerStyle={styles.listaConteudo}
          showsVerticalScrollIndicator={false}
        >
          {cards.map((classe) => {
            const ativo = selecionada.key === classe.key;
            return (
              <TouchableOpacity
                key={classe.key}
                style={[styles.card, ativo && styles.cardAtivo]}
                onPress={() => setSelecionada(classe)}
                activeOpacity={0.85}
              >
                <View style={styles.cardTopo}>
                  <Text style={styles.emoji}>{classe.emoji}</Text>
                  <View style={styles.cardTextos}>
                    <Text style={styles.cardTitulo}>{classe.nome}</Text>
                    <Text style={styles.cardDescricao}>{classe.descricao}</Text>
                  </View>
                </View>
                <View style={styles.bonusWrap}>
                  {classe.bonus.map((tag) => (
                    <View
                      key={tag}
                      style={[
                        styles.bonusTag,
                        { backgroundColor: `${classe.cor}2E` },
                      ]}
                    >
                      <Text style={[styles.bonusTexto, { color: classe.cor }]}>
                        {tag}
                      </Text>
                    </View>
                  ))}
                </View>
              </TouchableOpacity>
            );
          })}
        </ScrollView>

        <TouchableOpacity
          style={styles.botaoContinuar}
          onPress={() => {
            void AsyncStorage.multiSet([
              ['classe_selecionada', selecionada.key],
              ['classe_nome', selecionada.nome],
              ['emoji_classe', selecionada.emoji],
            ]);
            navigation.navigate('EscolhaAvatar', {
              classeKey: selecionada.key,
              classeNome: selecionada.nome,
              emojiClasse: selecionada.emoji,
            });
          }}
          activeOpacity={0.85}
        >
          <Text style={styles.textoContinuar}>Continuar →</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.botaoVoltar}
          onPress={() => navigation.replace('Welcome')}
          activeOpacity={0.7}
        >
          <Text style={styles.textoVoltar}>← Voltar</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  areaSegura: {
    flex: 1,
    backgroundColor: cores.fundoInferior,
  },
  fundo: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: cores.fundoSuperior,
  },
  conteudo: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 8,
  },
  barraProgresso: {
    flexDirection: 'row',
    gap: 8,
  },
  segmento: {
    flex: 1,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgba(255,255,255,0.12)',
  },
  segmentoAtivo: {
    backgroundColor: cores.roxoPrimario,
  },
  passo: {
    marginTop: 20,
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 1.2,
    color: 'rgba(255,255,255,0.55)',
  },
  titulo: {
    marginTop: 8,
    fontSize: 28,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  subtitulo: {
    marginTop: 6,
    fontSize: 16,
    color: 'rgba(255,255,255,0.55)',
  },
  lista: {
    flex: 1,
    marginTop: 20,
  },
  listaConteudo: {
    gap: 12,
    paddingBottom: 16,
  },
  card: {
    borderRadius: 18,
    padding: 16,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.10)',
  },
  cardAtivo: {
    borderWidth: 2.5,
    borderColor: cores.roxoPrimario,
  },
  cardTopo: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 14,
  },
  emoji: {
    fontSize: 36,
    width: 48,
    textAlign: 'center',
  },
  cardTextos: {
    flex: 1,
  },
  cardTitulo: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  cardDescricao: {
    marginTop: 4,
    fontSize: 14,
    color: 'rgba(255,255,255,0.55)',
    lineHeight: 20,
  },
  bonusWrap: {
    marginTop: 12,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  bonusTag: {
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  bonusTexto: {
    fontSize: 12,
    fontWeight: '600',
  },
  botaoContinuar: {
    backgroundColor: cores.roxoPrimario,
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: 'center',
  },
  textoContinuar: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: '600',
  },
  botaoVoltar: {
    paddingVertical: 14,
    alignItems: 'center',
  },
  textoVoltar: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 16,
    fontWeight: '500',
  },
});
