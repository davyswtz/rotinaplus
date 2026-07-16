import React, { useMemo } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { cores } from '../theme/colors';

export type MissaoDoDia = {
  id: number;
  icone: string;
  titulo: string;
  detalhe: string;
  xp: number;
  concluida: boolean;
};

export const MISSOES_EXEMPLO: MissaoDoDia[] = [
  {
    id: 1,
    icone: '💧',
    titulo: 'Beber água',
    detalhe: '2L ao longo do dia',
    xp: 15,
    concluida: true,
  },
  {
    id: 2,
    icone: '🏃',
    titulo: 'Treinar',
    detalhe: '30 min de movimento',
    xp: 25,
    concluida: true,
  },
  {
    id: 3,
    icone: '📚',
    titulo: 'Estudar',
    detalhe: '1 Pomodoro focado',
    xp: 20,
    concluida: false,
  },
  {
    id: 4,
    icone: '🧘',
    titulo: 'Meditar',
    detalhe: '10 min de respiração',
    xp: 15,
    concluida: false,
  },
  {
    id: 5,
    icone: '💰',
    titulo: 'Registrar gastos',
    detalhe: 'Anotar o dia no app',
    xp: 10,
    concluida: false,
  },
];

type Props = {
  missoes: MissaoDoDia[];
  onToggle: (id: number) => void;
};

/** Lista de missões do dia — espelha MissoesDoDiaView.swift. */
export function MissoesDoDiaView({ missoes, onToggle }: Props) {
  const concluidas = useMemo(
    () => missoes.filter((m) => m.concluida).length,
    [missoes],
  );

  return (
    <View style={styles.container}>
      <View style={styles.cabecalho}>
        <Text style={styles.titulo}>MISSÕES DO DIA</Text>
        <Text style={styles.contador}>
          {concluidas}/{missoes.length}
        </Text>
      </View>

      <View style={styles.lista}>
        {missoes.map((missao) => (
          <TouchableOpacity
            key={missao.id}
            style={[styles.card, missao.concluida && styles.cardConcluida]}
            onPress={() => onToggle(missao.id)}
            activeOpacity={0.85}
          >
            <View
              style={[
                styles.iconeWrap,
                missao.concluida && styles.iconeWrapConcluida,
              ]}
            >
              <Text style={styles.icone}>{missao.icone}</Text>
            </View>

            <View style={styles.textoColuna}>
              <Text
                style={[
                  styles.tituloMissao,
                  missao.concluida && styles.tituloConcluida,
                ]}
              >
                {missao.titulo}
              </Text>
              <Text
                style={[
                  styles.detalhe,
                  missao.concluida && styles.detalheConcluida,
                ]}
              >
                {missao.detalhe}
              </Text>
            </View>

            <Text style={styles.xp}>+{missao.xp}xp</Text>
            <Text style={[styles.check, missao.concluida && styles.checkConcluida]}>
              {missao.concluida ? '✓' : '○'}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: 12,
  },
  cabecalho: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  titulo: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 11,
    fontWeight: '600',
    letterSpacing: 0.8,
    fontVariant: ['tabular-nums'],
  },
  contador: {
    color: cores.roxoPrimario,
    fontSize: 12,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
  },
  lista: {
    gap: 10,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  cardConcluida: {
    backgroundColor: '#0F1E17',
    borderColor: '#4ADE80',
    borderWidth: 1.5,
  },
  iconeWrap: {
    width: 36,
    height: 36,
    borderRadius: 10,
    backgroundColor: 'rgba(255,255,255,0.06)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconeWrapConcluida: {
    backgroundColor: 'rgba(74, 222, 128, 0.12)',
  },
  icone: {
    fontSize: 20,
  },
  textoColuna: {
    flex: 1,
    gap: 3,
  },
  tituloMissao: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
  },
  tituloConcluida: {
    textDecorationLine: 'line-through',
    color: 'rgba(255,255,255,0.45)',
  },
  detalhe: {
    color: 'rgba(255,255,255,0.45)',
    fontSize: 12,
  },
  detalheConcluida: {
    color: 'rgba(255,255,255,0.28)',
  },
  xp: {
    color: '#4ADE80',
    fontSize: 11,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
  },
  check: {
    fontSize: 18,
    width: 24,
    textAlign: 'center',
    color: 'rgba(255,255,255,0.35)',
  },
  checkConcluida: {
    color: '#4ADE80',
    fontWeight: '700',
  },
});
