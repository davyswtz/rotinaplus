import React, { useState } from 'react';
import {
  ActivityIndicator,
  Modal,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { cores } from '../theme/colors';

const ICONES = ['⚔️', '💧', '🏃', '📚', '🧘', '💰', '🔥', '🦊', '📖', '🎯'];

type Props = {
  visible: boolean;
  onClose: () => void;
  onSalvar: (dados: {
    titulo: string;
    detalhe?: string;
    icone: string;
  }) => Promise<void>;
};

export function AdicionarMissaoModal({ visible, onClose, onSalvar }: Props) {
  const [titulo, setTitulo] = useState('');
  const [detalhe, setDetalhe] = useState('');
  const [icone, setIcone] = useState('🎯');
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  const reset = () => {
    setTitulo('');
    setDetalhe('');
    setIcone('🎯');
    setErro(null);
    setSalvando(false);
  };

  const handleClose = () => {
    reset();
    onClose();
  };

  const handleSalvar = async () => {
    const limpo = titulo.trim();
    if (!limpo || salvando) return;

    setSalvando(true);
    setErro(null);
    try {
      await onSalvar({
        titulo: limpo,
        detalhe: detalhe.trim() || undefined,
        icone,
      });
      reset();
      onClose();
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Falha ao criar missão.');
      setSalvando(false);
    }
  };

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={handleClose}>
      <View style={styles.overlay}>
        <View style={styles.sheet}>
          <View style={styles.header}>
            <Text style={styles.titulo}>Nova missão</Text>
            <TouchableOpacity onPress={handleClose} activeOpacity={0.7}>
              <Text style={styles.cancelar}>Cancelar</Text>
            </TouchableOpacity>
          </View>

          <ScrollView showsVerticalScrollIndicator={false}>
            <Text style={styles.label}>Ícone</Text>
            <View style={styles.gradeIcones}>
              {ICONES.map((emoji) => (
                <TouchableOpacity
                  key={emoji}
                  style={[styles.iconeTile, icone === emoji && styles.iconeAtivo]}
                  onPress={() => setIcone(emoji)}
                  activeOpacity={0.85}
                >
                  <Text style={styles.emoji}>{emoji}</Text>
                </TouchableOpacity>
              ))}
            </View>

            <Text style={styles.label}>Título</Text>
            <TextInput
              style={styles.input}
              placeholder="Ex: Beber água"
              placeholderTextColor="rgba(255,255,255,0.35)"
              value={titulo}
              onChangeText={setTitulo}
              editable={!salvando}
            />

            <Text style={styles.label}>Detalhe (opcional)</Text>
            <TextInput
              style={styles.input}
              placeholder="Ex: 2L ao longo do dia"
              placeholderTextColor="rgba(255,255,255,0.35)"
              value={detalhe}
              onChangeText={setDetalhe}
              editable={!salvando}
            />

            <Text style={styles.dicaXp}>
              O XP é calculado automaticamente com base no seu nível — quanto maior o
              desafio descrito, maior a recompensa justa.
            </Text>

            {erro ? <Text style={styles.erro}>{erro}</Text> : null}

            <TouchableOpacity
              style={[
                styles.botaoSalvar,
                (!titulo.trim() || salvando) && styles.botaoDesabilitado,
              ]}
              onPress={() => {
                void handleSalvar();
              }}
              disabled={!titulo.trim() || salvando}
              activeOpacity={0.85}
            >
              {salvando ? (
                <ActivityIndicator color="#FFF" />
              ) : (
                <Text style={styles.textoSalvar}>Criar missão</Text>
              )}
            </TouchableOpacity>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.55)',
  },
  sheet: {
    maxHeight: '88%',
    backgroundColor: '#0D081A',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 24,
    paddingTop: 20,
    paddingBottom: 32,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  titulo: {
    color: '#FFF',
    fontSize: 20,
    fontWeight: '700',
  },
  cancelar: {
    color: 'rgba(255,255,255,0.65)',
    fontSize: 15,
  },
  label: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 12,
    fontWeight: '600',
    marginBottom: 8,
    marginTop: 12,
  },
  gradeIcones: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  iconeTile: {
    width: '18%',
    aspectRatio: 1,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconeAtivo: {
    borderWidth: 2,
    borderColor: cores.roxoPrimario,
  },
  emoji: {
    fontSize: 26,
  },
  input: {
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 14,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.14)',
    color: '#FFF',
    fontSize: 16,
  },
  dicaXp: {
    marginTop: 16,
    color: 'rgba(255,255,255,0.45)',
    fontSize: 13,
    lineHeight: 18,
  },
  erro: {
    color: cores.erro,
    marginTop: 12,
    textAlign: 'center',
  },
  botaoSalvar: {
    marginTop: 24,
    backgroundColor: cores.roxoPrimario,
    borderRadius: 14,
    paddingVertical: 16,
    alignItems: 'center',
  },
  botaoDesabilitado: {
    opacity: 0.45,
  },
  textoSalvar: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
});
