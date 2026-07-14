import React from 'react';
import { StyleSheet, Text, useWindowDimensions, View } from 'react-native';
import { getLayoutDashboard } from '../theme/layout';

export type DadosGradeStats = {
  streakDias: number;
  habitosHojeConcluidos: number;
  habitosHojeTotal: number;
  xpHoje: number;
  moedas: number;
};

type Props = {
  dados: DadosGradeStats;
};

type Item = {
  icone: string;
  cor: string;
  valor: string;
  label: string;
};

function StatCard({
  item,
  compacto,
}: {
  item: Item;
  compacto: boolean;
}) {
  return (
    <View style={[styles.card, compacto && styles.cardCompacto]}>
      <Text style={[styles.icone, { color: item.cor, fontSize: compacto ? 16 : 18 }]}>
        {item.icone}
      </Text>
      <Text
        style={[styles.valor, { fontSize: compacto ? 15 : 16 }]}
        numberOfLines={1}
        adjustsFontSizeToFit
        minimumFontScale={0.65}
      >
        {item.valor}
      </Text>
      <Text style={[styles.label, { fontSize: compacto ? 9 : 10 }]} numberOfLines={1}>
        {item.label}
      </Text>
    </View>
  );
}

/** Grade 4 stats responsiva — em telas estreitas vira 2×2. */
export function GradeStatsDashboard({ dados }: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const gap = layout.gapGrade;

  const itens: Item[] = [
    {
      icone: '🔥',
      cor: '#FF8C47',
      valor: `${dados.streakDias}d`,
      label: 'STREAK',
    },
    {
      icone: '✅',
      cor: '#4DD972',
      valor: `${dados.habitosHojeConcluidos}/${dados.habitosHojeTotal}`,
      label: 'HOJE',
    },
    {
      icone: '⭐',
      cor: '#9E6BFA',
      valor: `+${dados.xpHoje}`,
      label: 'XP HOJE',
    },
    {
      icone: '👑',
      cor: '#FFD147',
      valor: `${dados.moedas}`,
      label: 'MOEDAS',
    },
  ];

  if (layout.compacto) {
    return (
      <View style={{ gap }}>
        <View style={[styles.grade, { gap }]}>
          {itens.slice(0, 2).map((item) => (
            <StatCard key={item.label} item={item} compacto />
          ))}
        </View>
        <View style={[styles.grade, { gap }]}>
          {itens.slice(2, 4).map((item) => (
            <StatCard key={item.label} item={item} compacto />
          ))}
        </View>
      </View>
    );
  }

  return (
    <View style={[styles.grade, { gap }]}>
      {itens.map((item) => (
        <StatCard key={item.label} item={item} compacto={false} />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  grade: {
    flexDirection: 'row',
  },
  card: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    paddingHorizontal: 4,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.05)',
    gap: 8,
  },
  cardCompacto: {
    paddingVertical: 12,
    gap: 6,
  },
  icone: {
    fontSize: 18,
  },
  valor: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  label: {
    color: 'rgba(255,255,255,0.40)',
    fontWeight: '600',
    letterSpacing: 0.4,
  },
});
