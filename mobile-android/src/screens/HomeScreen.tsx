import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  ImageSourcePropType,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  useWindowDimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import { HeaderApp } from '../components/HeaderApp';
import { CardPerfilHeroi } from '../components/CardPerfilHeroi';
import { GradeStatsDashboard } from '../components/GradeStatsDashboard';
import { ProgressoDiarioCard } from '../components/ProgressoDiarioCard';
import { MissoesDoDiaView, MissaoDoDia } from '../components/MissoesDoDiaView';
import { AtalhosRapidosView } from '../components/AtalhosRapidosView';
import { AbaFooter, FooterNavegacao } from '../components/FooterNavegacao';
import { AcademiaScreen } from './AcademiaScreen';
import { FinancasScreen } from './FinancasScreen';
import { cores } from '../theme/colors';
import { getLayoutDashboard } from '../theme/layout';
import { useAuthStore } from '../store/authStore';
import { RootStackParamList } from '../navigation/AppNavigator';
import {
  fetchDashboard,
  toggleMissao,
  criarMissao,
} from '../services/rotinaApi';
import type { Perfil } from '../types';
import { avatarAssetKey } from '../types';
import { AdicionarMissaoModal } from '../components/AdicionarMissaoModal';

type Nav = NativeStackNavigationProp<RootStackParamList, 'Home'>;

const AVATARES: Record<string, ImageSourcePropType> = {
  guara_serio: require('../assets/avatars/avatar_guara_serio.png'),
  guara_sorriso: require('../assets/avatars/avatar_guara_sorriso.png'),
  guara_sono: require('../assets/avatars/avatar_guara_sono.png'),
  guara_surpreso: require('../assets/avatars/avatar_guara_surpreso.png'),
  bussola: require('../assets/avatars/avatar_bussola.png'),
  mapa_escrevendo: require('../assets/avatars/avatar_mapa_escrevendo.png'),
  corda: require('../assets/avatars/avatar_corda.png'),
  lanterna: require('../assets/avatars/avatar_lanterna.png'),
  mapa_tesouro: require('../assets/avatars/avatar_mapa_tesouro.png'),
  clava: require('../assets/avatars/avatar_clava.png'),
  pergaminho: require('../assets/avatars/avatar_pergaminho.png'),
  bolsa_moedas: require('../assets/avatars/avatar_bolsa_moedas.png'),
  emblema_clavas: require('../assets/avatars/avatar_emblema_clavas.png'),
  escudo: require('../assets/avatars/avatar_escudo.png'),
  map_maker: require('../assets/avatars/avatar_map_maker.png'),
  selo: require('../assets/avatars/avatar_selo.png'),
};

function missaoFromApi(m: {
  id: number;
  icone: string;
  titulo: string;
  detalhe: string | null;
  xp: number;
  concluida: boolean;
}): MissaoDoDia {
  return {
    id: m.id,
    icone: m.icone,
    titulo: m.titulo,
    detalhe: m.detalhe ?? '',
    xp: m.xp,
    concluida: m.concluida,
  };
}

export function HomeScreen() {
  const navigation = useNavigation<Nav>();
  const logout = useAuthStore((state) => state.logout);
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const [perfil, setPerfil] = useState<Perfil | null>(null);
  const [notificacoesNaoLidas, setNotificacoesNaoLidas] = useState(0);
  const [missoes, setMissoes] = useState<MissaoDoDia[]>([]);
  const [aba, setAba] = useState<AbaFooter>('inicio');
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [mostrarAdicionarMissao, setMostrarAdicionarMissao] = useState(false);

  const pad = layout.paddingHorizontal;
  const gap = layout.gapSecao;

  const carregar = useCallback(async () => {
    setErro(null);
    try {
      const data = await fetchDashboard();
      setPerfil(data.perfil);
      setMissoes(data.missoes.map(missaoFromApi));
      setNotificacoesNaoLidas(data.notificacoes_nao_lidas);

      if (data.perfil.nome_heroi?.trim()) {
        await AsyncStorage.setItem('nome_heroi', data.perfil.nome_heroi.trim());
      }
      await AsyncStorage.setItem(
        'avatar_selecionado',
        avatarAssetKey(data.perfil.avatar_key),
      );
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro ao carregar.');
    } finally {
      setCarregando(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void carregar();
  }, [carregar]);

  useFocusEffect(
    useCallback(() => {
      void carregar();
    }, [carregar]),
  );

  const concluidas = useMemo(
    () => missoes.filter((m) => m.concluida).length,
    [missoes],
  );
  const xpHoje = useMemo(
    () =>
      missoes.filter((m) => m.concluida).reduce((soma, m) => soma + m.xp, 0),
    [missoes],
  );

  const avatarId = avatarAssetKey(perfil?.avatar_key ?? 'guara_serio');
  const nome =
    perfil?.nome_heroi?.trim().toLowerCase() || 'herói';

  const dados = useMemo(
    () => ({
      nomeUsuario: nome,
      nivel: perfil?.nivel ?? 1,
      streakDias: perfil?.streak_dias ?? 0,
      moedas: perfil?.moedas ?? 0,
      notificacoes: notificacoesNaoLidas,
      avatarSource: AVATARES[avatarId] ?? AVATARES.guara_serio,
    }),
    [nome, perfil, avatarId, notificacoesNaoLidas],
  );

  const onToggleMissao = async (id: number) => {
    setMissoes((atual) =>
      atual.map((m) =>
        m.id === id ? { ...m, concluida: !m.concluida } : m,
      ),
    );
    try {
      await toggleMissao(id);
      await carregar();
    } catch {
      setMissoes((atual) =>
        atual.map((m) =>
          m.id === id ? { ...m, concluida: !m.concluida } : m,
        ),
      );
    }
  };

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <HeaderApp
        dados={dados}
        onToquePerfil={() => setAba('perfil')}
        onToqueNotificacoes={() => {
          navigation.navigate('Notificacoes');
        }}
      />

      {aba === 'inicio' ? (
        <ScrollView
          contentContainerStyle={styles.scroll}
          showsVerticalScrollIndicator={false}
          style={styles.flex}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={() => {
                setRefreshing(true);
                void carregar();
              }}
              tintColor="#fff"
            />
          }
        >
          {carregando && !perfil ? (
            <ActivityIndicator color="#fff" style={{ marginTop: 40 }} />
          ) : erro && !perfil ? (
            <View style={styles.placeholder}>
              <Text style={styles.placeholderTexto}>{erro}</Text>
              <TouchableOpacity
                style={styles.botao}
                onPress={() => {
                  setCarregando(true);
                  void carregar();
                }}
              >
                <Text style={styles.textoBotao}>Tentar de novo</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <>
              <View
                style={[styles.cardWrap, { paddingHorizontal: pad, paddingTop: gap }]}
              >
                <CardPerfilHeroi
                  dados={{
                    nomeUsuario: nome,
                    classe: perfil?.classe ?? 'Sábio',
                    emojiClasse: perfil?.emoji_classe ?? '🔮',
                    nivel: perfil?.nivel ?? 1,
                    xpAtual: perfil?.xp_atual ?? 0,
                    xpProximoNivel: perfil?.xp_proximo_nivel ?? 500,
                    avatarSource: AVATARES[avatarId] ?? AVATARES.guara_serio,
                  }}
                />
              </View>

              <View style={[styles.bloco, { paddingHorizontal: pad, paddingTop: gap }]}>
                <GradeStatsDashboard
                  dados={{
                    streakDias: perfil?.streak_dias ?? 0,
                    habitosHojeConcluidos: concluidas,
                    habitosHojeTotal: Math.max(missoes.length, 1),
                    xpHoje,
                    moedas: perfil?.moedas ?? 0,
                  }}
                />
              </View>

              <View style={[styles.bloco, { paddingHorizontal: pad, paddingTop: gap }]}>
                <ProgressoDiarioCard
                  dados={{
                    concluidos: concluidas,
                    total: Math.max(missoes.length, 1),
                  }}
                />
              </View>

              <View
                style={[styles.bloco, { paddingHorizontal: pad, paddingTop: gap + 4 }]}
              >
                <MissoesDoDiaView
                  missoes={missoes}
                  onToggle={onToggleMissao}
                  onAdicionar={() => setMostrarAdicionarMissao(true)}
                />
              </View>

              <View
                style={[
                  styles.bloco,
                  { paddingHorizontal: pad, paddingTop: gap + 4, paddingBottom: 16 },
                ]}
              >
                <AtalhosRapidosView
                  onAtalho={(_id, abaDestino) => {
                    if (abaDestino) setAba(abaDestino);
                  }}
                />
              </View>
            </>
          )}
        </ScrollView>
      ) : aba === 'academia' ? (
        <AcademiaScreen />
      ) : aba === 'financas' ? (
        <FinancasScreen />
      ) : (
        <View style={styles.placeholder}>
          <Text style={styles.placeholderTitulo}>
            {aba === 'perfil' ? 'Perfil' : 'Estudos'}
          </Text>
          <Text style={styles.placeholderTexto}>
            {aba === 'perfil'
              ? 'Em breve: editar herói, classe e preferências.'
              : 'Esta área chega nas próximas etapas.'}
          </Text>
          {aba === 'perfil' ? (
            <TouchableOpacity
              style={styles.botao}
              onPress={logout}
              activeOpacity={0.85}
            >
              <Text style={styles.textoBotao}>Sair</Text>
            </TouchableOpacity>
          ) : null}
        </View>
      )}

      <FooterNavegacao abaSelecionada={aba} onSelecionar={setAba} />

      <AdicionarMissaoModal
        visible={mostrarAdicionarMissao}
        onClose={() => setMostrarAdicionarMissao(false)}
        onSalvar={async (dados) => {
          const criada = await criarMissao(dados);
          setMissoes((atual) => [...atual, missaoFromApi(criada)]);
          await carregar();
        }}
      />
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
  flex: {
    flex: 1,
  },
  scroll: {
    paddingBottom: 16,
  },
  cardWrap: {},
  bloco: {},
  placeholder: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
    gap: 12,
  },
  placeholderTitulo: {
    color: '#FFFFFF',
    fontSize: 22,
    fontWeight: '700',
  },
  placeholderTexto: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 15,
    textAlign: 'center',
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
