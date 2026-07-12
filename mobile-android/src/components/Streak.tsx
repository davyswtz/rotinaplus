import React from 'react'
import { View, Text, StyleSheet } from 'react-native'

type Props = {
  days?: string
}

export default function Streak({ days = '3d' }: Props) {
  return (
    <View style={styles.card}>
      <View style={styles.iconCircle}>
        <Text style={styles.icon}>🔥</Text>
      </View>
      <Text style={styles.value}>{days}</Text>
      <Text style={styles.label}>STREAK</Text>
    </View>
  )
}

const styles = StyleSheet.create({
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
