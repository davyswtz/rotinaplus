import React, { useMemo, useState } from 'react';
import {
  Image,
  ImageSourcePropType,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RouteProp, useNavigation, useRoute } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { cores } from '../theme/colors';
import { RootStackParamList } from '../navigation/AppNavigator';

type Nav = NativeStackNavigationProp<RootStackParamList, 'NomeHeroi'>;
type Rota = RouteProp<RootStackParamList, 'NomeHeroi'>;

const LIMITE_NOME = 20;

const AVATAR_SOURCES: Record<string, ImageSourcePropType> = {
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

function tracoDoAvatar(id: string): { emoji: string; nome: string } {
  if (id.startsWith('guara_')) return { emoji: '🦊', nome: 'Explorador' };
  if (['mapa_escrevendo', 'mapa_tesouro', 'pergaminho', 'map_maker'].includes(id)) {
    return { emoji: '📚', nome: 'Estudioso' };
  }
  if (['bussola', 'lanterna', 'corda'].includes(id)) {
    return { emoji: '🧭', nome: 'Navegador' };
  }
  if (['clava', 'emblema_clavas', 'escudo'].includes(id)) {
    return { emoji: '⚔️', nome: 'Guerreiro' };
  }
  return { emoji: '🏆', nome: 'Colecionador' };
}

/** Passo 3 de 3 — espelha TelaNomeHeroi.swift / mock. */
export function NomeHeroiScreen() {
  const navigation = useNavigation<Nav>();
  const route = useRoute<Rota>();
  const avatarId = route.params?.avatarId ?? 'guara_serio';
  const [nome, setNome] = useState('');

  const source = AVATAR_SOURCES[avatarId] ?? AVATAR_SOURCES.guara_serio;
  const traco = useMemo(() => tracoDoAvatar(avatarId), [avatarId]);
  const nomeValido = nome.trim().length > 0;

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <View style={styles.conteudo}>
        <View style={styles.barraProgresso}>
          <View style={[styles.segmento, styles.segmentoAtivo]} />
          <View style={[styles.segmento, styles.segmentoAtivo]} />
          <View style={[styles.segmento, styles.segmentoAtivo]} />
        </View>

        <Text style={styles.passo}>PASSO 3 DE 3</Text>
        <Text style={styles.titulo}>Seu nome de herói</Text>
        <Text style={styles.subtitulo}>Como o mundo vai te conhecer</Text>

        <View style={styles.previewArea}>
          <View style={styles.previewTile}>
            <Image source={source} style={styles.previewIcone} resizeMode="contain" />
          </View>
          <View style={styles.chip}>
            <Text style={styles.chipTexto}>
              {traco.emoji} {traco.nome}
            </Text>
          </View>
        </View>

        <Text style={styles.labelNome}>NOME DO HERÓI</Text>
        <TextInput
          style={styles.input}
          placeholder="Ex: Arthur, Sora, Neo..."
          placeholderTextColor="rgba(255,255,255,0.35)"
          value={nome}
          onChangeText={(texto) => setNome(texto.slice(0, LIMITE_NOME))}
          autoCapitalize="words"
          autoCorrect={false}
          maxLength={LIMITE_NOME}
        />
        <Text style={styles.contador}>
          {nome.length}/{LIMITE_NOME}
        </Text>

        <View style={styles.espacador} />

        <TouchableOpacity
          style={[styles.botaoComecar, !nomeValido && styles.botaoDesabilitado]}
          onPress={() => {
            if (!nomeValido) return;
            void AsyncStorage.setItem('nome_heroi', nome.trim());
            navigation.replace('Home');
          }}
          activeOpacity={0.85}
          disabled={!nomeValido}
        >
          <Text style={styles.textoComecar}>Começar aventura 🦊⚡</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.botaoVoltar}
          onPress={() => navigation.replace('EscolhaAvatar')}
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
  previewArea: {
    marginTop: 32,
    alignItems: 'center',
  },
  previewTile: {
    width: 148,
    height: 148,
    borderRadius: 22,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 2,
    borderColor: 'rgba(115, 209, 230, 0.75)',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 18,
  },
  previewIcone: {
    width: '100%',
    height: '100%',
  },
  chip: {
    marginTop: 14,
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.06)',
  },
  chipTexto: {
    color: '#73D1E6',
    fontSize: 15,
    fontWeight: '600',
  },
  labelNome: {
    marginTop: 28,
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 1,
    color: 'rgba(255,255,255,0.55)',
  },
  input: {
    marginTop: 8,
    borderRadius: 18,
    paddingHorizontal: 18,
    paddingVertical: 16,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.14)',
    color: '#FFFFFF',
    fontSize: 16,
  },
  contador: {
    marginTop: 8,
    alignSelf: 'flex-end',
    fontSize: 12,
    color: 'rgba(255,255,255,0.55)',
  },
  espacador: {
    flex: 1,
  },
  botaoComecar: {
    backgroundColor: cores.roxoPrimario,
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: 'center',
  },
  botaoDesabilitado: {
    opacity: 0.45,
  },
  textoComecar: {
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
