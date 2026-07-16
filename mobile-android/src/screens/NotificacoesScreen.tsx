import React, { useCallback, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { cores } from '../theme/colors';
import { RootStackParamList } from '../navigation/AppNavigator';
import {
  fetchNotificacoes,
  lerTodasNotificacoes,
  marcarNotificacaoLida,
} from '../services/rotinaApi';
import type { Notificacao } from '../types';

type Nav = NativeStackNavigationProp<RootStackParamList, 'Notificacoes'>;

export function NotificacoesScreen() {
  const navigation = useNavigation<Nav>();
  const [itens, setItens] = useState<Notificacao[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);
  const naoLidas = useMemo(() => itens.filter((i) => !i.lida).length, [itens]);

  const carregar = useCallback(async () => {
    setErro(null);
    try {
      const lista = await fetchNotificacoes();
      setItens(lista);
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro ao carregar.');
    } finally {
      setCarregando(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      setCarregando(true);
      void carregar();
    }, [carregar]),
  );

  const marcarLida = async (id: number) => {
    const item = itens.find((i) => i.id === id);
    if (!item || item.lida) return;
    setItens((atual) =>
      atual.map((n) => (n.id === id ? { ...n, lida: true } : n)),
    );
    try {
      await marcarNotificacaoLida(id);
    } catch {
      setItens((atual) =>
        atual.map((n) => (n.id === id ? { ...n, lida: false } : n)),
      );
    }
  };

  const marcarTodas = async () => {
    setItens((atual) => atual.map((item) => ({ ...item, lida: true })));
    try {
      await lerTodasNotificacoes();
    } catch {
      void carregar();
    }
  };

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <View style={styles.cabecalho}>
        <TouchableOpacity
          style={styles.botaoVoltar}
          onPress={() => navigation.goBack()}
          activeOpacity={0.8}
        >
          <Text style={styles.voltarIcone}>‹</Text>
        </TouchableOpacity>

        <Text style={styles.titulo}>Notificações</Text>

        <TouchableOpacity
          onPress={() => void marcarTodas()}
          disabled={naoLidas === 0}
          activeOpacity={0.8}
          style={styles.botaoLerTodas}
        >
          <Text
            style={[
              styles.textoLerTodas,
              naoLidas === 0 && styles.textoLerTodasOff,
            ]}
          >
            Ler todas
          </Text>
        </TouchableOpacity>
      </View>

      {carregando ? (
        <ActivityIndicator color="#fff" style={{ marginTop: 40 }} />
      ) : erro ? (
        <View style={styles.erroBox}>
          <Text style={styles.erroTexto}>{erro}</Text>
          <TouchableOpacity onPress={() => void carregar()}>
            <Text style={styles.textoLerTodas}>Tentar de novo</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={itens}
          keyExtractor={(item) => String(item.id)}
          contentContainerStyle={styles.lista}
          showsVerticalScrollIndicator={false}
          renderItem={({ item }) => (
            <TouchableOpacity
              style={[styles.card, !item.lida && styles.cardNaoLida]}
              onPress={() => void marcarLida(item.id)}
              activeOpacity={0.85}
            >
              {!item.lida ? <View style={styles.ponto} /> : null}
              <Text style={styles.icone}>{item.icone}</Text>
              <View style={styles.textoColuna}>
                <Text style={styles.cardTitulo}>{item.titulo}</Text>
                <Text style={styles.cardMensagem}>{item.mensagem}</Text>
                <Text style={styles.cardQuando}>{item.quando}</Text>
              </View>
            </TouchableOpacity>
          )}
        />
      )}
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
    backgroundColor: cores.fundoSuperior,
  },
  cabecalho: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 16,
  },
  botaoVoltar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.08)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  voltarIcone: {
    color: '#FFFFFF',
    fontSize: 28,
    lineHeight: 30,
    marginTop: -2,
  },
  titulo: {
    flex: 1,
    textAlign: 'center',
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '700',
  },
  botaoLerTodas: {
    minWidth: 72,
    alignItems: 'flex-end',
  },
  textoLerTodas: {
    color: cores.roxoPrimario,
    fontSize: 14,
    fontWeight: '600',
  },
  textoLerTodasOff: {
    color: 'rgba(255,255,255,0.35)',
  },
  lista: {
    paddingHorizontal: 16,
    paddingBottom: 24,
    gap: 10,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 14,
    padding: 16,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1.5,
    borderColor: 'transparent',
  },
  cardNaoLida: {
    backgroundColor: '#24173D',
    borderColor: 'rgba(122, 66, 245, 0.55)',
  },
  ponto: {
    position: 'absolute',
    top: 12,
    right: 12,
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: cores.roxoPrimario,
  },
  icone: {
    fontSize: 28,
    width: 36,
    textAlign: 'center',
    marginTop: 2,
  },
  textoColuna: {
    flex: 1,
    gap: 6,
  },
  cardTitulo: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  cardMensagem: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 14,
    lineHeight: 20,
  },
  cardQuando: {
    marginTop: 2,
    color: 'rgba(255,255,255,0.35)',
    fontSize: 12,
  },
  erroBox: {
    padding: 24,
    alignItems: 'center',
    gap: 12,
  },
  erroTexto: {
    color: 'rgba(255,255,255,0.55)',
    textAlign: 'center',
  },
});
