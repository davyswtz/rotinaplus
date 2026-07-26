import React, { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
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
import { ClasseHeroi, mapClasseApi } from '../data/classes';
import { fetchClasses } from '../services/rotinaApi';

type Nav = NativeStackNavigationProp<RootStackParamList, 'EscolhaClasse'>;

/** Passo 1 de 3 — classes vindas da API. */
export function EscolhaClasseScreen() {
  const navigation = useNavigation<Nav>();
  const [classes, setClasses] = useState<ClasseHeroi[]>([]);
  const [selecionada, setSelecionada] = useState<ClasseHeroi | null>(null);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);

  const carregar = useCallback(async () => {
    setCarregando(true);
    setErro(null);
    try {
      const lista = (await fetchClasses()).map(mapClasseApi);
      setClasses(lista);
      setSelecionada((atual) => atual ?? lista[0] ?? null);
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro ao carregar classes.');
    } finally {
      setCarregando(false);
    }
  }, []);

  useEffect(() => {
    void carregar();
  }, [carregar]);

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

        {carregando ? (
          <ActivityIndicator color="#fff" style={{ marginTop: 40 }} />
        ) : erro ? (
          <View style={styles.erroBox}>
            <Text style={styles.erroTexto}>{erro}</Text>
            <TouchableOpacity onPress={() => void carregar()}>
              <Text style={styles.erroRetry}>Tentar de novo</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <>
            <ScrollView
              style={styles.lista}
              contentContainerStyle={styles.listaConteudo}
              showsVerticalScrollIndicator={false}
            >
              {classes.map((classe) => {
                const ativo = selecionada?.key === classe.key;
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
              style={[styles.botaoContinuar, !selecionada && styles.botaoDesabilitado]}
              disabled={!selecionada}
              onPress={() => {
                if (!selecionada) return;
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
          </>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  areaSegura: { flex: 1, backgroundColor: cores.fundoTela },
  fundo: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: cores.fundoSuperior,
  },
  conteudo: { flex: 1, paddingHorizontal: 24, paddingTop: 8 },
  barraProgresso: { flexDirection: 'row', gap: 8, marginBottom: 20 },
  segmento: {
    flex: 1,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgba(255,255,255,0.12)',
  },
  segmentoAtivo: { backgroundColor: cores.roxoPrimario },
  passo: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 1.2,
  },
  titulo: {
    color: '#fff',
    fontSize: 28,
    fontWeight: '700',
    marginTop: 8,
  },
  subtitulo: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 15,
    marginTop: 6,
    marginBottom: 16,
  },
  lista: { flex: 1 },
  listaConteudo: { gap: 12, paddingBottom: 16 },
  card: {
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 18,
    padding: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.10)',
  },
  cardAtivo: {
    borderColor: cores.roxoPrimario,
    borderWidth: 2.5,
  },
  cardTopo: { flexDirection: 'row', gap: 14 },
  emoji: { fontSize: 36, width: 48, textAlign: 'center' },
  cardTextos: { flex: 1 },
  cardTitulo: { color: '#fff', fontSize: 18, fontWeight: '700' },
  cardDescricao: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 14,
    marginTop: 4,
  },
  bonusWrap: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12 },
  bonusTag: {
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  bonusTexto: { fontSize: 12, fontWeight: '600' },
  botaoContinuar: {
    backgroundColor: cores.roxoPrimario,
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: 'center',
    marginBottom: 12,
  },
  botaoDesabilitado: { opacity: 0.45 },
  textoContinuar: { color: '#fff', fontWeight: '600', fontSize: 16 },
  erroBox: { marginTop: 32, gap: 12 },
  erroTexto: { color: 'rgba(255,255,255,0.65)' },
  erroRetry: { color: cores.roxoPrimario, fontWeight: '600' },
});
