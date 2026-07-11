import React from 'react';
import { StyleSheet, Text, TouchableOpacity } from 'react-native';
import { cores } from '../theme/colors';

// MARK: - Botão de login social (Google / Apple)
// Componente reutilizável; conecte onPress ao SDK de cada provedor depois.

interface SocialLoginButtonProps {
  /** Texto exibido no botão, ex.: "Continuar com Google" */
  title: string;
  /** Ícone ou emoji exibido à esquerda do texto */
  icon: string;
  onPress: () => void;
  disabled?: boolean;
}

export function SocialLoginButton({
  title,
  icon,
  onPress,
  disabled = false,
}: SocialLoginButtonProps) {
  return (
    <TouchableOpacity
      style={[styles.botao, disabled && styles.desabilitado]}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.75}
    >
      <Text style={styles.icone}>{icon}</Text>
      <Text style={styles.titulo}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  botao: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: cores.botaoSocialFundo,
    borderWidth: 1,
    borderColor: cores.botaoSocialBorda,
    borderRadius: 14,
    paddingVertical: 14,
    paddingHorizontal: 20,
    marginBottom: 12,
  },
  desabilitado: {
    opacity: 0.5,
  },
  icone: {
    fontSize: 18,
    marginRight: 10,
  },
  titulo: {
    color: cores.textoPrimario,
    fontSize: 15,
    fontWeight: '600',
  },
});
