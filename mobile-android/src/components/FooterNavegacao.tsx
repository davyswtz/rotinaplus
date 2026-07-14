import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  useWindowDimensions,
  View,
} from 'react-native';
import { cores } from '../theme/colors';
import { getLayoutDashboard } from '../theme/layout';

export type AbaFooter =
  | 'inicio'
  | 'academia'
  | 'financas'
  | 'estudos'
  | 'perfil';

const ABAS: { id: AbaFooter; titulo: string; icone: string }[] = [
  { id: 'inicio', titulo: 'Início', icone: '🏠' },
  { id: 'academia', titulo: 'Academia', icone: '🏋️' },
  { id: 'financas', titulo: 'Finanças', icone: '💳' },
  { id: 'estudos', titulo: 'Estudos', icone: '📖' },
  { id: 'perfil', titulo: 'Perfil', icone: '👤' },
];

type Props = {
  abaSelecionada: AbaFooter;
  onSelecionar: (aba: AbaFooter) => void;
};

/** Footer responsivo. */
export function FooterNavegacao({ abaSelecionada, onSelecionar }: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);

  return (
    <View
      style={[
        styles.wrap,
        { paddingHorizontal: layout.paddingHorizontal, paddingBottom: 8 },
      ]}
    >
      <View
        style={[
          styles.barra,
          { paddingVertical: layout.compacto ? 6 : 8 },
        ]}
      >
        {ABAS.map((aba) => {
          const ativo = abaSelecionada === aba.id;
          return (
            <TouchableOpacity
              key={aba.id}
              style={[styles.item, ativo && styles.itemAtivo]}
              onPress={() => onSelecionar(aba.id)}
              activeOpacity={0.85}
            >
              <View
                style={[styles.indicador, ativo && styles.indicadorAtivo]}
              />
              <Text style={{ fontSize: layout.compacto ? 14 : 16 }}>
                {aba.icone}
              </Text>
              <Text
                style={[
                  styles.titulo,
                  ativo && styles.textoAtivo,
                  { fontSize: layout.compacto ? 9 : 10 },
                ]}
                numberOfLines={1}
                adjustsFontSizeToFit
                minimumFontScale={0.7}
              >
                {aba.titulo}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {},
  barra: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 999,
    paddingHorizontal: 6,
    backgroundColor: '#1A1229',
    borderWidth: 1,
    borderColor: 'rgba(122, 66, 245, 0.35)',
  },
  item: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 6,
    borderRadius: 14,
    gap: 3,
  },
  itemAtivo: {
    backgroundColor: 'rgba(255,255,255,0.08)',
  },
  indicador: {
    width: 16,
    height: 3,
    borderRadius: 2,
    backgroundColor: 'transparent',
  },
  indicadorAtivo: {
    backgroundColor: cores.roxoPrimario,
  },
  titulo: {
    fontWeight: '500',
    color: 'rgba(255,255,255,0.40)',
  },
  textoAtivo: {
    color: cores.roxoPrimario,
  },
});
