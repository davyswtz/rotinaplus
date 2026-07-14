import React, { useMemo } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { cores } from '../theme/colors';

export type DadosProgressoDiario = {
  concluidos: number;
  total: number;
};

type Props = {
  dados: DadosProgressoDiario;
};

/** Card de progresso diário — espelha ProgressoDiarioCard.swift. */
export function ProgressoDiarioCard({ dados }: Props) {
  const fracao = useMemo(() => {
    if (dados.total <= 0) return 0;
    return Math.min(1, dados.concluidos / dados.total);
  }, [dados.concluidos, dados.total]);

  const percentual = Math.round(fracao * 100);

  return (
    <View style={styles.card}>
      <View style={styles.topo}>
        <Text style={styles.label}>PROGRESSO DIÁRIO</Text>
        <Text style={styles.percentual}>{percentual}%</Text>
      </View>
      <View style={styles.track}>
        <View style={[styles.fill, { width: `${fracao * 100}%` }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: 'rgba(122, 66, 245, 0.28)',
    gap: 12,
  },
  topo: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  label: {
    color: '#B89DEB',
    fontSize: 11,
    fontWeight: '600',
    letterSpacing: 0.8,
    fontVariant: ['tabular-nums'],
  },
  percentual: {
    color: '#73F28C',
    fontSize: 13,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
  },
  track: {
    height: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.08)',
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
    borderRadius: 999,
    backgroundColor: cores.roxoPrimario,
  },
});
