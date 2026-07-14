import React, { useMemo, useState } from 'react';
import {
  FlatList,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useNavigation } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { cores } from '../theme/colors';
import { RootStackParamList } from '../navigation/AppNavigator';

type Nav = NativeStackNavigationProp<RootStackParamList, 'Notificacoes'>;

export type NotificacaoItem = {
  id: string;
  icone: string;
  titulo: string;
  mensagem: string;
  quando: string;
  lida: boolean;
};

const EXEMPLOS: NotificacaoItem[] = [
  {
    id: '1',
    icone: '🔥',
    titulo: 'Streak em risco!',
    mensagem:
      'Complete pelo menos 1 hábito hoje para manter sua sequência de 3 dias.',
    quando: 'Agora',
    lida: false,
  },
  {
    id: '2',
    icone: '⚡',
    titulo: 'XP desbloqueado',
    mensagem:
      'Você ganhou 35 XP pela missão diária de hidratação. Continue assim!',
    quando: '2h atrás',
    lida: false,
  },
  {
    id: '3',
    icone: '🏆',
    titulo: 'Conquista próxima',
    mensagem:
      'Faltam 2 treinos para desbloquear a medalha Guerreiro Consistente.',
    quando: '4h atrás',
    lida: true,
  },
  {
    id: '4',
    icone: '🦊',
    titulo: 'Fox diz: Boa noite!',
    mensagem:
      'Lembre de registrar seus hábitos antes de dormir. Seu eu de amanhã agradece.',
    quando: 'Ontem',
    lida: true,
  },
  {
    id: '5',
    icone: '💰',
    titulo: 'Meta de poupança 69%',
    mensagem: 'Você está quase lá! Faltam R$ 620 para bater a meta do mês.',
    quando: 'Ontem',
    lida: true,
  },
  {
    id: '6',
    icone: '📚',
    titulo: 'Hora de estudar',
    mensagem: 'Que tal uma sessão de Pomodoro agora? 25 min fazem diferença.',
    quando: '2 dias',
    lida: true,
  },
];

/** Espelha TelaNotificacoes.swift / mock. */
export function NotificacoesScreen() {
  const navigation = useNavigation<Nav>();
  const [itens, setItens] = useState<NotificacaoItem[]>(EXEMPLOS);
  const naoLidas = useMemo(() => itens.filter((i) => !i.lida).length, [itens]);

  const marcarLida = (id: string) => {
    setItens((atual) =>
      atual.map((item) => (item.id === id ? { ...item, lida: true } : item)),
    );
  };

  const marcarTodas = () => {
    setItens((atual) => atual.map((item) => ({ ...item, lida: true })));
  };

  return (
    <SafeAreaView style={styles.areaSegura}>
      <View style={styles.fundo} />

      <View style={styles.cabecalho}>
        <TouchableOpacity
          style={styles.botaoVoltar}
          onPress={() => navigation.goBack()}
          activeOpacity={0.8}
        >
          <Text style={styles.voltarIcone}>‹</Text>
        </TouchableOpacity>

        <Text style={styles.titulo}>Notificações</Text>

        <TouchableOpacity
          onPress={marcarTodas}
          disabled={naoLidas === 0}
          activeOpacity={0.8}
          style={styles.botaoLerTodas}
        >
          <Text
            style={[
              styles.textoLerTodas,
              naoLidas === 0 && styles.textoLerTodasOff,
            ]}
          >
            Ler todas
          </Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={itens}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.lista}
        showsVerticalScrollIndicator={false}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={[styles.card, !item.lida && styles.cardNaoLida]}
            onPress={() => marcarLida(item.id)}
            activeOpacity={0.85}
          >
            {!item.lida ? <View style={styles.ponto} /> : null}
            <Text style={styles.icone}>{item.icone}</Text>
            <View style={styles.textoColuna}>
              <Text style={styles.cardTitulo}>{item.titulo}</Text>
              <Text style={styles.cardMensagem}>{item.mensagem}</Text>
              <Text style={styles.cardQuando}>{item.quando}</Text>
            </View>
          </TouchableOpacity>
        )}
      />
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
    backgroundColor: cores.fundoSuperior,
  },
  cabecalho: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 16,
  },
  botaoVoltar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.08)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  voltarIcone: {
    color: '#FFFFFF',
    fontSize: 28,
    lineHeight: 30,
    marginTop: -2,
  },
  titulo: {
    flex: 1,
    textAlign: 'center',
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '700',
  },
  botaoLerTodas: {
    minWidth: 72,
    alignItems: 'flex-end',
  },
  textoLerTodas: {
    color: cores.roxoPrimario,
    fontSize: 14,
    fontWeight: '600',
  },
  textoLerTodasOff: {
    color: 'rgba(255,255,255,0.35)',
  },
  lista: {
    paddingHorizontal: 16,
    paddingBottom: 24,
    gap: 10,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 14,
    padding: 16,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1.5,
    borderColor: 'transparent',
  },
  cardNaoLida: {
    backgroundColor: '#24173D',
    borderColor: 'rgba(122, 66, 245, 0.55)',
  },
  ponto: {
    position: 'absolute',
    top: 12,
    right: 12,
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: cores.roxoPrimario,
  },
  icone: {
    fontSize: 28,
    width: 36,
    textAlign: 'center',
    marginTop: 2,
  },
  textoColuna: {
    flex: 1,
    gap: 6,
  },
  cardTitulo: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  cardMensagem: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 14,
    lineHeight: 20,
  },
  cardQuando: {
    marginTop: 2,
    color: 'rgba(255,255,255,0.35)',
    fontSize: 12,
  },
});
