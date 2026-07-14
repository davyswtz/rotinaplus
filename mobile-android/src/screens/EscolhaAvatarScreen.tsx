import React, { useState } from 'react';
import {
  Image,
  ImageSourcePropType,
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

type Nav = NativeStackNavigationProp<RootStackParamList, 'EscolhaAvatar'>;

const AVATARES: { id: string; source: ImageSourcePropType }[] = [
  { id: 'guara_serio', source: require('../assets/avatars/avatar_guara_serio.png') },
  { id: 'guara_sorriso', source: require('../assets/avatars/avatar_guara_sorriso.png') },
  { id: 'guara_sono', source: require('../assets/avatars/avatar_guara_sono.png') },
  { id: 'guara_surpreso', source: require('../assets/avatars/avatar_guara_surpreso.png') },
  { id: 'bussola', source: require('../assets/avatars/avatar_bussola.png') },
  { id: 'mapa_escrevendo', source: require('../assets/avatars/avatar_mapa_escrevendo.png') },
  { id: 'corda', source: require('../assets/avatars/avatar_corda.png') },
  { id: 'lanterna', source: require('../assets/avatars/avatar_lanterna.png') },
  { id: 'mapa_tesouro', source: require('../assets/avatars/avatar_mapa_tesouro.png') },
  { id: 'clava', source: require('../assets/avatars/avatar_clava.png') },
  { id: 'pergaminho', source: require('../assets/avatars/avatar_pergaminho.png') },
  { id: 'bolsa_moedas', source: require('../assets/avatars/avatar_bolsa_moedas.png') },
  { id: 'emblema_clavas', source: require('../assets/avatars/avatar_emblema_clavas.png') },
  { id: 'escudo', source: require('../assets/avatars/avatar_escudo.png') },
  { id: 'map_maker', source: require('../assets/avatars/avatar_map_maker.png') },
  { id: 'selo', source: require('../assets/avatars/avatar_selo.png') },
];

/** Passo 2 de 3 — espelha TelaEscolhaAvatar.swift / mock. */
export function EscolhaAvatarScreen() {
  const navigation = useNavigation<Nav>();
  const [selecionado, setSelecionado] = useState(AVATARES[0].id);

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <View style={styles.conteudo}>
        <View style={styles.barraProgresso}>
          <View style={[styles.segmento, styles.segmentoAtivo]} />
          <View style={[styles.segmento, styles.segmentoAtivo]} />
          <View style={styles.segmento} />
        </View>

        <Text style={styles.passo}>PASSO 2 DE 3</Text>
        <Text style={styles.titulo}>Escolha seu avatar</Text>
        <Text style={styles.subtitulo}>Sua identidade visual no mundo</Text>

        <View style={styles.grade}>
          {AVATARES.map((avatar) => {
            const ativo = selecionado === avatar.id;
            return (
              <TouchableOpacity
                key={avatar.id}
                style={[styles.tile, ativo && styles.tileAtivo]}
                onPress={() => setSelecionado(avatar.id)}
                activeOpacity={0.85}
              >
                <Image source={avatar.source} style={styles.icone} resizeMode="contain" />
              </TouchableOpacity>
            );
          })}
        </View>

        <View style={styles.espacador} />

        <TouchableOpacity
          style={styles.botaoContinuar}
          onPress={() => navigation.replace('Home')}
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
  grade: {
    marginTop: 28,
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    rowGap: 12,
  },
  tile: {
    width: '22%',
    aspectRatio: 1,
    borderRadius: 14,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 6,
  },
  tileAtivo: {
    borderWidth: 2.5,
    borderColor: cores.roxoPrimario,
  },
  icone: {
    width: '100%',
    height: '100%',
  },
  espacador: {
    flex: 1,
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
