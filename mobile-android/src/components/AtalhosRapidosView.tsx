import React from 'react';
import {
  Image,
  StyleSheet,
  Text,
  TouchableOpacity,
  useWindowDimensions,
  View,
} from 'react-native';
import { getLayoutDashboard } from '../theme/layout';
import { AbaFooter } from './FooterNavegacao';

export type AtalhoRapidoId =
  | 'treino'
  | 'financas'
  | 'estudar'
  | 'ranking'
  | 'loja'
  | 'conquistas';

const ATALHOS: {
  id: AtalhoRapidoId;
  icone: string;
  titulo: string;
  aba?: AbaFooter;
}[] = [
  { id: 'treino', icone: '🏋️', titulo: 'Treino', aba: 'academia' },
  { id: 'financas', icone: '📊', titulo: 'Finanças', aba: 'financas' },
  { id: 'estudar', icone: '📚', titulo: 'Estudar', aba: 'estudos' },
  { id: 'ranking', icone: '🏆', titulo: 'Ranking' },
  { id: 'loja', icone: '🛒', titulo: 'Loja' },
  { id: 'conquistas', icone: '🎯', titulo: 'Conquistas' },
];

type Props = {
  mensagemFox?: string;
  onAtalho?: (id: AtalhoRapidoId, aba?: AbaFooter) => void;
};

/** Atalhos rápidos responsivos. */
export function AtalhosRapidosView({
  mensagemFox = 'Bora começar as missões, herói! 🦊',
  onAtalho,
}: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);

  return (
    <View style={[styles.container, { gap: layout.gapSecao }]}>
      <Text style={[styles.titulo, { fontSize: layout.fonte(17) }]}>
        Atalhos rápidos
      </Text>

      <View style={[styles.grade, { gap: layout.gapGrade }]}>
        {ATALHOS.map((atalho) => (
          <TouchableOpacity
            key={atalho.id}
            style={[
              styles.card,
              {
                width: layout.cardAtalho,
                paddingVertical: layout.compacto ? 12 : 16,
              },
            ]}
            onPress={() => onAtalho?.(atalho.id, atalho.aba)}
            activeOpacity={0.85}
          >
            <Text style={{ fontSize: layout.compacto ? 22 : 26 }}>
              {atalho.icone}
            </Text>
            <Text
              style={[styles.label, { fontSize: layout.fonte(12) }]}
              numberOfLines={1}
              adjustsFontSizeToFit
              minimumFontScale={0.7}
            >
              {atalho.titulo}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.foxCard}>
        <Image
          source={require('../assets/splash_guara.png')}
          style={{
            width: layout.compacto ? 40 : 44,
            height: layout.compacto ? 40 : 44,
          }}
          resizeMode="contain"
        />
        <View style={styles.foxTexto}>
          <Text style={styles.foxTitulo}>Fox diz:</Text>
          <Text style={[styles.foxMensagem, { fontSize: layout.fonte(13) }]}>
            {mensagemFox}
          </Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {},
  titulo: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  grade: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  card: {
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: 'rgba(122, 66, 245, 0.28)',
    gap: 8,
  },
  label: {
    color: 'rgba(255,255,255,0.55)',
    fontWeight: '500',
  },
  foxCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: 'rgba(122, 66, 245, 0.28)',
  },
  foxTexto: {
    flex: 1,
    gap: 4,
  },
  foxTitulo: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
  foxMensagem: {
    color: 'rgba(255,255,255,0.55)',
  },
});
