import React, { useMemo } from 'react';
import {
  Image,
  ImageSourcePropType,
  StyleSheet,
  Text,
  useWindowDimensions,
  View,
} from 'react-native';
import { cores } from '../theme/colors';
import { getLayoutDashboard } from '../theme/layout';

export type DadosCardPerfil = {
  nomeUsuario: string;
  classe?: string;
  emojiClasse?: string;
  nivel: number;
  xpAtual: number;
  xpProximoNivel: number;
  avatarSource: ImageSourcePropType;
};

type Props = {
  dados: DadosCardPerfil;
};

function saudacaoDoDia(): string {
  const hora = new Date().getHours();
  if (hora >= 5 && hora < 12) return 'BOM DIA, HERÓI';
  if (hora >= 12 && hora < 18) return 'BOA TARDE, HERÓI';
  return 'BOA NOITE, HERÓI';
}

/** Card de resumo do herói responsivo. */
export function CardPerfilHeroi({ dados }: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const avatar = layout.compacto ? 60 : 72;
  const glow = layout.compacto ? 76 : 88;

  const progresso = useMemo(() => {
    if (dados.xpProximoNivel <= 0) return 0;
    return Math.min(1, dados.xpAtual / dados.xpProximoNivel);
  }, [dados.xpAtual, dados.xpProximoNivel]);

  return (
    <View style={[styles.card, { padding: layout.compacto ? 14 : 18 }]}>
      <View style={styles.topo}>
        <View style={styles.info}>
          <Text
            style={[styles.saudacao, { fontSize: layout.fonte(11) }]}
            numberOfLines={1}
          >
            {saudacaoDoDia()}
          </Text>
          <Text
            style={[styles.nome, { fontSize: layout.fonte(28) }]}
            numberOfLines={1}
            adjustsFontSizeToFit
            minimumFontScale={0.7}
          >
            {dados.nomeUsuario.toLowerCase()}
          </Text>
          <View style={styles.chip}>
            <Text style={styles.chipTexto}>
              {dados.emojiClasse ?? '🔮'} {dados.classe ?? 'Sábio'}
            </Text>
          </View>
        </View>

        <View style={[styles.avatarWrap, { width: glow + 8, height: glow + 12 }]}>
          <View
            style={[
              styles.glow,
              { width: glow, height: glow, borderRadius: glow / 2 },
            ]}
          />
          <Image
            source={dados.avatarSource}
            style={{
              width: avatar,
              height: avatar,
              borderRadius: avatar / 2,
              borderWidth: 1,
              borderColor: 'rgba(255,255,255,0.12)',
            }}
          />
          <Image
            source={require('../assets/splash_guara.png')}
            style={[
              styles.mascote,
              {
                width: layout.compacto ? 24 : 28,
                height: layout.compacto ? 24 : 28,
              },
            ]}
            resizeMode="contain"
          />
        </View>
      </View>

      <View style={styles.xpLinha}>
        <View style={styles.nivel}>
          <Text style={styles.nivelTexto}>{dados.nivel}</Text>
        </View>
        <View style={styles.barraTrack}>
          <View style={[styles.barraFill, { width: `${progresso * 100}%` }]} />
        </View>
        <Text
          style={[styles.xpTexto, { fontSize: layout.fonte(12) }]}
          numberOfLines={1}
        >
          {dados.xpAtual}/{dados.xpProximoNivel}
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 22,
    backgroundColor: '#24173D',
    borderWidth: 1,
    borderColor: 'rgba(122, 66, 245, 0.35)',
  },
  topo: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  info: {
    flex: 1,
    paddingRight: 8,
  },
  saudacao: {
    fontWeight: '600',
    letterSpacing: 0.8,
    color: 'rgba(255,255,255,0.55)',
  },
  nome: {
    marginTop: 8,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  chip: {
    alignSelf: 'flex-start',
    marginTop: 8,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.08)',
  },
  chipTexto: {
    color: '#B894FF',
    fontSize: 13,
    fontWeight: '600',
  },
  avatarWrap: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  glow: {
    position: 'absolute',
    backgroundColor: 'rgba(122, 66, 245, 0.22)',
  },
  mascote: {
    position: 'absolute',
    right: 0,
    bottom: 0,
  },
  xpLinha: {
    marginTop: 18,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  nivel: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: cores.roxoPrimario,
    alignItems: 'center',
    justifyContent: 'center',
  },
  nivelTexto: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700',
  },
  barraTrack: {
    flex: 1,
    height: 8,
    borderRadius: 999,
    backgroundColor: 'rgba(0,0,0,0.35)',
    overflow: 'hidden',
  },
  barraFill: {
    height: '100%',
    borderRadius: 999,
    backgroundColor: cores.roxoPrimario,
  },
  xpTexto: {
    color: 'rgba(255,255,255,0.45)',
    fontWeight: '500',
  },
});
