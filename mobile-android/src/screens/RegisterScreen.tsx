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
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useNavigation } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { PrimaryButton } from '../components/PrimaryButton';
import { SocialLoginButton } from '../components/SocialLoginButton';
import { useAuth } from '../hooks/useAuth';
import { RootStackParamList } from '../navigation/AppNavigator';
import { cores } from '../theme/colors';

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'Register'>;

// MARK: - Tela de Criar Conta (Android / React Native)
// Layout espelhado do CadastroView.swift no iOS e do LoginScreen.tsx.

export function RegisterScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [localError, setLocalError] = useState<string | null>(null);

  const { register, isLoading, error } = useAuth();

  const handleRegister = () => {
    const nome = name.trim();
    const emailTrim = email.trim();

    if (!nome || !emailTrim || !password || !passwordConfirmation) {
      setLocalError('Preencha todos os campos.');
      return;
    }

    if (password !== passwordConfirmation) {
      setLocalError('A confirmação de senha não confere.');
      return;
    }

    if (password.length < 8) {
      setLocalError('A senha deve ter pelo menos 8 caracteres.');
      return;
    }

    setLocalError(null);
    void register(nome, emailTrim, password, passwordConfirmation);
  };

  const handleGoogleLogin = () => {
    // TODO: integrar Google Sign-In e enviar token para /api/v1/auth/social
  };

  const handleAppleLogin = () => {
    // TODO: integrar Sign in with Apple e enviar token para /api/v1/auth/social
  };

  const erroExibido = localError ?? error;

  return (
    <SafeAreaView style={styles.areaSegura}>
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
          <View style={styles.cabecalho}>
            <Text style={styles.mascote}>🐾</Text>
            <Text style={styles.titulo}>Criar conta no RotinaPlus</Text>
            <Text style={styles.subtitulo}>
              Comece sua aventura RPG e transforme hábitos em XP.
            </Text>
          </View>

          <View style={styles.formulario}>
            <Text style={styles.rotulo}>Nome</Text>
            <TextInput
              style={styles.campo}
              placeholder="Seu nome"
              placeholderTextColor={cores.textoPlaceholder}
              value={name}
              onChangeText={setName}
              autoCapitalize="words"
              autoCorrect={false}
            />

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
              placeholder="Mínimo 8 caracteres"
              placeholderTextColor={cores.textoPlaceholder}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />

            <Text style={styles.rotulo}>Confirmar senha</Text>
            <TextInput
              style={styles.campo}
              placeholder="Repita a senha"
              placeholderTextColor={cores.textoPlaceholder}
              value={passwordConfirmation}
              onChangeText={setPasswordConfirmation}
              secureTextEntry
            />
          </View>

          {erroExibido ? <Text style={styles.erro}>{erroExibido}</Text> : null}

          <PrimaryButton
            title={isLoading ? 'Criando conta...' : 'Criar conta'}
            onPress={handleRegister}
            disabled={isLoading}
          />

          {isLoading ? (
            <ActivityIndicator
              style={styles.carregando}
              color={cores.roxoPrimario}
            />
          ) : null}

          <View style={styles.divisor}>
            <View style={styles.linhaDivisor} />
            <Text style={styles.textoDivisor}>ou continue com</Text>
            <View style={styles.linhaDivisor} />
          </View>

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

          <View style={styles.rodape}>
            <Text style={styles.textoRodape}>Já tem conta? </Text>
            <TouchableOpacity
              onPress={() => navigation.navigate('Login')}
              activeOpacity={0.7}
            >
              <Text style={styles.linkEntrar}>Entrar</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

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
  erro: {
    color: cores.erro,
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 12,
  },
  carregando: {
    marginTop: 12,
  },
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
  social: {
    marginBottom: 24,
  },
  rodape: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  textoRodape: {
    color: cores.textoSecundario,
    fontSize: 14,
  },
  linkEntrar: {
    color: cores.roxoPrimario,
    fontSize: 14,
    fontWeight: '600',
  },
});
