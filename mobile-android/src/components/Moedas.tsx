import React from 'react'
import { View, StyleSheet, Text } from 'react-native'
import Streak from './Streak'
import Hoje from './Hoje'
import XpHoje from './XpHoje'

function MoedasCard({ amount = '480' }: { amount?: string }) {
  return (
    <View style={cardStyles.card}>
      <View style={cardStyles.iconCircle}>
        <Text style={cardStyles.icon}>👑</Text>
      </View>
      <Text style={cardStyles.value}>{amount}</Text>
      <Text style={cardStyles.label}>MOEDAS</Text>
    </View>
  )
}

export default function MoedasContainer() {
  return (
    <View style={styles.container}>
      <Streak />
      <Hoje />
      <XpHoje />
      <MoedasCard />
      <View style={styles.spacer} />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    gap: 12,
    padding: 8,
    alignItems: 'center',
  },
  spacer: {
    flex: 1,
  },
})

const cardStyles = StyleSheet.create({
  card: {
    backgroundColor: '#0f1724',
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 16,
    alignItems: 'center',
    width: 84,
  },
  iconCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#0b1220',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
  },
  icon: {
    fontSize: 18,
  },
  value: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '700',
  },
  label: {
    color: '#9ca3af',
    fontSize: 11,
    marginTop: 4,
  },
})
