import React from 'react';
import {
  Image,
  ImageSourcePropType,
  StyleSheet,
  Text,
  TouchableOpacity,
  useWindowDimensions,
  View,
} from 'react-native';
import { cores } from '../theme/colors';
import { getLayoutDashboard } from '../theme/layout';

export type DadosHeaderApp = {
  tituloApp?: string;
  nomeUsuario: string;
  nivel: number;
  streakDias: number;
  moedas: number;
  notificacoes: number;
  avatarSource?: ImageSourcePropType;
};

type Props = {
  dados: DadosHeaderApp;
  onToquePerfil?: () => void;
  onToqueNotificacoes?: () => void;
};

const AVATAR_PADRAO = require('../assets/avatars/avatar_guara_serio.png');

/** Header responsivo — espelha HeaderApp.swift. */
export function HeaderApp({
  dados,
  onToquePerfil,
  onToqueNotificacoes,
}: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const titulo = dados.tituloApp ?? 'Rotina Plus';
  const badge =
    dados.notificacoes > 9 ? '9+' : String(dados.notificacoes);
  const avatarSize = layout.compacto ? 32 : 36;

  return (
    <View
      style={[
        styles.container,
        {
          paddingHorizontal: layout.paddingHorizontal,
          paddingVertical: layout.compacto ? 8 : 10,
        },
      ]}
    >
      <TouchableOpacity
        style={styles.identidade}
        onPress={onToquePerfil}
        activeOpacity={0.8}
      >
        <Image
          source={dados.avatarSource ?? AVATAR_PADRAO}
          style={{
            width: avatarSize,
            height: avatarSize,
            borderRadius: avatarSize / 2,
            borderWidth: 1,
            borderColor: 'rgba(255,255,255,0.12)',
            backgroundColor: 'rgba(255,255,255,0.06)',
          }}
          resizeMode="cover"
        />
        <View style={styles.textoIdentidade}>
          <Text
            style={[styles.titulo, { fontSize: layout.fonte(15) }]}
            numberOfLines={1}
          >
            {titulo}
          </Text>
          <Text
            style={[styles.subtitulo, { fontSize: layout.fonte(12) }]}
            numberOfLines={1}
          >
            {dados.nomeUsuario} · Lv.{dados.nivel}
          </Text>
        </View>
      </TouchableOpacity>

      <View style={[styles.direita, { gap: layout.compacto ? 6 : 8 }]}>
        {!layout.estreito ? (
          <View style={[styles.chip, styles.chipStreak]}>
            <Text style={[styles.chipTextoStreak, { fontSize: layout.fonte(12) }]}>
              🔥 {dados.streakDias}d
            </Text>
          </View>
        ) : null}

        <View style={[styles.chip, styles.chipMoeda]}>
          <Text style={[styles.chipTextoMoeda, { fontSize: layout.fonte(12) }]}>
            👑 {dados.moedas}
          </Text>
        </View>

        <TouchableOpacity
          style={[
            styles.sino,
            { width: avatarSize, height: avatarSize, borderRadius: avatarSize / 2 },
          ]}
          onPress={onToqueNotificacoes}
          activeOpacity={0.8}
        >
          <Text style={styles.sinoIcone}>🔔</Text>
          {dados.notificacoes > 0 ? (
            <View style={styles.badge}>
              <Text style={styles.badgeTexto}>{badge}</Text>
            </View>
          ) : null}
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  identidade: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    flexShrink: 1,
    flex: 1,
  },
  textoIdentidade: {
    flexShrink: 1,
  },
  titulo: {
    fontWeight: '600',
    color: 'rgba(255,255,255,0.88)',
  },
  subtitulo: {
    marginTop: 2,
    fontWeight: '500',
    color: cores.roxoPrimario,
  },
  direita: {
    flexDirection: 'row',
    alignItems: 'center',
    flexShrink: 0,
  },
  chip: {
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 7,
  },
  chipStreak: {
    backgroundColor: 'rgba(90, 35, 28, 0.95)',
  },
  chipMoeda: {
    backgroundColor: 'rgba(80, 65, 25, 0.95)',
  },
  chipTextoStreak: {
    color: '#FF8C47',
    fontWeight: '600',
  },
  chipTextoMoeda: {
    color: '#FFD147',
    fontWeight: '600',
  },
  sino: {
    backgroundColor: 'rgba(255,255,255,0.08)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  sinoIcone: {
    fontSize: 15,
  },
  badge: {
    position: 'absolute',
    top: -3,
    right: -4,
    minWidth: 16,
    height: 16,
    borderRadius: 8,
    paddingHorizontal: 4,
    backgroundColor: '#EB3840',
    alignItems: 'center',
    justifyContent: 'center',
  },
  badgeTexto: {
    color: '#FFFFFF',
    fontSize: 9,
    fontWeight: '700',
  },
});
