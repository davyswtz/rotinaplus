import React, { useMemo, useState } from 'react';
import {
  ImageSourcePropType,
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
import { useNavigation } from '@react-navigation/native';
import { HeaderApp } from '../components/HeaderApp';
import { CardPerfilHeroi } from '../components/CardPerfilHeroi';
import { GradeStatsDashboard } from '../components/GradeStatsDashboard';
import { ProgressoDiarioCard } from '../components/ProgressoDiarioCard';
import {
  MissoesDoDiaView,
  MISSOES_EXEMPLO,
  MissaoDoDia,
} from '../components/MissoesDoDiaView';
import { AtalhosRapidosView } from '../components/AtalhosRapidosView';
import { AbaFooter, FooterNavegacao } from '../components/FooterNavegacao';
import { AcademiaScreen } from './AcademiaScreen';
import { cores } from '../theme/colors';
import { getLayoutDashboard } from '../theme/layout';
import { useAuthStore } from '../store/authStore';
import { RootStackParamList } from '../navigation/AppNavigator';

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

// MARK: - Dashboard inicial (espelha HomeView.swift)
export function HomeScreen() {
  const navigation = useNavigation<Nav>();
  const logout = useAuthStore((state) => state.logout);
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const [nome, setNome] = useState('herói');
  const [avatarId, setAvatarId] = useState('guara_serio');
  const [notificacoesNaoLidas, setNotificacoesNaoLidas] = useState(2);
  const [missoes, setMissoes] = useState<MissaoDoDia[]>(MISSOES_EXEMPLO);
  const [aba, setAba] = useState<AbaFooter>('inicio');

  const pad = layout.paddingHorizontal;
  const gap = layout.gapSecao;

  React.useEffect(() => {
    void Promise.all([
      AsyncStorage.getItem('nome_heroi'),
      AsyncStorage.getItem('avatar_selecionado'),
    ]).then(([nomeSalvo, avatarSalvo]) => {
      if (nomeSalvo?.trim()) {
        setNome(nomeSalvo.trim().toLowerCase());
      }
      if (avatarSalvo?.trim()) {
        const id = avatarSalvo.replace(/^avatar_/, '');
        setAvatarId(id);
      }
    });
  }, []);

  const concluidas = useMemo(
    () => missoes.filter((m) => m.concluida).length,
    [missoes],
  );
  const xpHoje = useMemo(
    () =>
      missoes.filter((m) => m.concluida).reduce((soma, m) => soma + m.xp, 0),
    [missoes],
  );

  const dados = useMemo(
    () => ({
      nomeUsuario: nome,
      nivel: 1,
      streakDias: 3,
      moedas: 480,
      notificacoes: notificacoesNaoLidas,
      avatarSource: AVATARES[avatarId] ?? AVATARES.guara_serio,
    }),
    [nome, avatarId, notificacoesNaoLidas],
  );

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <HeaderApp
        dados={dados}
        onToquePerfil={() => setAba('perfil')}
        onToqueNotificacoes={() => {
          setNotificacoesNaoLidas(0);
          navigation.navigate('Notificacoes');
        }}
      />

      {aba === 'inicio' ? (
        <ScrollView
          contentContainerStyle={styles.scroll}
          showsVerticalScrollIndicator={false}
          style={styles.flex}
        >
          <View style={[styles.cardWrap, { paddingHorizontal: pad, paddingTop: gap }]}>
            <CardPerfilHeroi
              dados={{
                nomeUsuario: nome,
                classe: 'Sábio',
                emojiClasse: '🔮',
                nivel: 1,
                xpAtual: 240,
                xpProximoNivel: 500,
                avatarSource: AVATARES[avatarId] ?? AVATARES.guara_serio,
              }}
            />
          </View>

          <View style={[styles.bloco, { paddingHorizontal: pad, paddingTop: gap }]}>
            <GradeStatsDashboard
              dados={{
                streakDias: 3,
                habitosHojeConcluidos: concluidas,
                habitosHojeTotal: missoes.length,
                xpHoje,
                moedas: 480,
              }}
            />
          </View>

          <View style={[styles.bloco, { paddingHorizontal: pad, paddingTop: gap }]}>
            <ProgressoDiarioCard
              dados={{ concluidos: concluidas, total: missoes.length }}
            />
          </View>

          <View style={[styles.bloco, { paddingHorizontal: pad, paddingTop: gap + 4 }]}>
            <MissoesDoDiaView
              missoes={missoes}
              onToggle={(id) => {
                setMissoes((atual) =>
                  atual.map((m) =>
                    m.id === id ? { ...m, concluida: !m.concluida } : m,
                  ),
                );
              }}
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
        </ScrollView>
      ) : aba === 'academia' ? (
        <AcademiaScreen />
      ) : (
        <View style={styles.placeholder}>
          <Text style={styles.placeholderTitulo}>
            {aba === 'perfil'
              ? 'Perfil'
              : aba === 'financas'
                ? 'Finanças'
                : 'Estudos'}
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
