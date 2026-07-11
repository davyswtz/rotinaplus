import React, { useState } from 'react';
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { PrimaryButton } from '../components/PrimaryButton';
import { SocialLoginButton } from '../components/SocialLoginButton';
import { useAuth } from '../hooks/useAuth';
import { cores } from '../theme/colors';

// MARK: - Tela de Login (Android / React Native)
// Layout espelhado do LoginView.swift no iOS.
// Apenas UI + hook useAuth; botões sociais são placeholders até integrar SDKs.

export function LoginScreen() {
  // MARK: - Estado local dos campos
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  // MARK: - Autenticação (e-mail/senha via API)
  const { login, isLoading, error } = useAuth();

  // MARK: - Ação do botão "Entrar"
  const handleLogin = () => {
    if (!email.trim() || !password.trim()) {
      return;
    }
    void login(email, password);
  };

  // MARK: - Ações dos botões sociais (somente front — conectar depois)
  const handleGoogleLogin = () => {
    // TODO: integrar Google Sign-In e enviar token para /api/v1/auth/social
  };

  const handleAppleLogin = () => {
    // TODO: integrar Sign in with Apple e enviar token para /api/v1/auth/social
  };

  // MARK: - Link "Esqueci minha senha" (somente front)
  const handleEsqueciSenha = () => {
    // TODO: navegar para tela de recuperação de senha
  };

  // MARK: - Link "Criar conta" (somente front)
  const handleCriarConta = () => {
    // TODO: navegar para tela de cadastro
  };

  return (
    <SafeAreaView style={styles.areaSegura}>
      {/* MARK: Fundo roxo escuro (mesma paleta do onboarding iOS) */}
      <View style={styles.fundo} />

      <KeyboardAvoidingView
        style={styles.teclado}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* MARK: Cabeçalho — mascote + título + subtítulo */}
          <View style={styles.cabecalho}>
            {/* TODO: substituir por Image(require('../assets/guara.png')) */}
            <Text style={styles.mascote}>🐾</Text>

            <Text style={styles.titulo}>Entrar no RotinaPlus</Text>

            <Text style={styles.subtitulo}>
              Continue sua aventura RPG e evolua seus hábitos diários.
            </Text>
          </View>

          {/* MARK: Formulário — e-mail e senha */}
          <View style={styles.formulario}>
            <Text style={styles.rotulo}>E-mail</Text>
            <TextInput
              style={styles.campo}
              placeholder="seu@email.com"
              placeholderTextColor={cores.textoPlaceholder}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />

            <Text style={styles.rotulo}>Senha</Text>
            <TextInput
              style={styles.campo}
              placeholder="••••••••"
              placeholderTextColor={cores.textoPlaceholder}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />

            {/* MARK: Link esqueci senha */}
            <TouchableOpacity
              style={styles.linkEsqueci}
              onPress={handleEsqueciSenha}
              activeOpacity={0.7}
            >
              <Text style={styles.textoLink}>Esqueci minha senha</Text>
            </TouchableOpacity>
          </View>

          {/* MARK: Mensagem de erro da API */}
          {error ? <Text style={styles.erro}>{error}</Text> : null}

          {/* MARK: Botão principal "Entrar" */}
          <PrimaryButton
            title={isLoading ? 'Entrando...' : 'Entrar'}
            onPress={handleLogin}
            disabled={isLoading}
          />

          {isLoading ? (
            <ActivityIndicator
              style={styles.carregando}
              color={cores.roxoPrimario}
            />
          ) : null}

          {/* MARK: Divisor "ou continue com" */}
          <View style={styles.divisor}>
            <View style={styles.linhaDivisor} />
            <Text style={styles.textoDivisor}>ou continue com</Text>
            <View style={styles.linhaDivisor} />
          </View>

          {/* MARK: Botões de login social */}
          <View style={styles.social}>
            <SocialLoginButton
              title="Continuar com Google"
              icon="G"
              onPress={handleGoogleLogin}
              disabled={isLoading}
            />
            <SocialLoginButton
              title="Continuar com Apple"
              icon={'\u{1F34E}'}
              onPress={handleAppleLogin}
              disabled={isLoading}
            />
          </View>

          {/* MARK: Rodapé — link para criar conta */}
          <View style={styles.rodape}>
            <Text style={styles.textoRodape}>Ainda não tem conta? </Text>
            <TouchableOpacity onPress={handleCriarConta} activeOpacity={0.7}>
              <Text style={styles.linkCriarConta}>Criar conta</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

// MARK: - Estilos da tela de login
const styles = StyleSheet.create({
  areaSegura: {
    flex: 1,
    backgroundColor: cores.fundoTela,
  },
  fundo: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: cores.fundoTela,
  },
  teclado: {
    flex: 1,
  },
  scroll: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingBottom: 32,
    justifyContent: 'center',
  },

  // Cabeçalho
  cabecalho: {
    alignItems: 'center',
    marginBottom: 32,
    marginTop: 16,
  },
  mascote: {
    fontSize: 56,
    marginBottom: 16,
  },
  titulo: {
    fontSize: 26,
    fontWeight: 'bold',
    color: cores.textoPrimario,
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitulo: {
    fontSize: 15,
    color: cores.textoSecundario,
    textAlign: 'center',
    lineHeight: 22,
    paddingHorizontal: 8,
  },

  // Formulário
  formulario: {
    marginBottom: 8,
  },
  rotulo: {
    color: cores.textoSecundario,
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 6,
    marginLeft: 4,
  },
  campo: {
    backgroundColor: cores.campoFundo,
    borderWidth: 1,
    borderColor: cores.campoBorda,
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    color: cores.textoPrimario,
    marginBottom: 16,
  },
  linkEsqueci: {
    alignSelf: 'flex-end',
    marginBottom: 8,
  },
  textoLink: {
    color: cores.roxoPrimario,
    fontSize: 14,
    fontWeight: '500',
  },

  // Feedback
  erro: {
    color: cores.erro,
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 12,
  },
  carregando: {
    marginTop: 12,
  },

  // Divisor social
  divisor: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 24,
  },
  linhaDivisor: {
    flex: 1,
    height: 1,
    backgroundColor: cores.campoBorda,
  },
  textoDivisor: {
    color: cores.textoSecundario,
    fontSize: 13,
    marginHorizontal: 12,
  },

  // Social
  social: {
    marginBottom: 24,
  },

  // Rodapé
  rodape: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  textoRodape: {
    color: cores.textoSecundario,
    fontSize: 14,
  },
  linkCriarConta: {
    color: cores.roxoPrimario,
    fontSize: 14,
    fontWeight: '600',
  },
});
