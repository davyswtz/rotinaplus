import React, { useCallback, useEffect, useState } from 'react';
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
import {
  concluirTreino,
  criarTreino,
  fetchCatalogoExercicios,
  fetchHistoricoTreinos,
  fetchTreino,
  toggleTreinoExercicio,
} from '../services/rotinaApi';
import type {
  AcademiaTreino,
  AcademiaTreinoExercicio,
  ExercicioCatalogo,
} from '../types';

const C = {
  primario: '#E87830',
  laranja: '#FF9B4A',
  verde: '#4ADE80',
  card: 'rgba(255,255,255,0.055)',
  borda: 'rgba(255,255,255,0.07)',
  label: 'rgba(255,255,255,0.42)',
  bg: '#1A1410',
};

type Draft = {
  key: string;
  chave: string;
  nome: string;
  icone: string;
  series: number;
  reps: number;
  carga_kg: number;
};

type NovoProps = {
  visible: boolean;
  treinoExistente?: AcademiaTreino | null;
  onClose: () => void;
  onSaved: () => void;
};

export function NovoTreinoModal({
  visible,
  treinoExistente,
  onClose,
  onSaved,
}: NovoProps) {
  const [focos, setFocos] = useState<string[]>([
    'Peito',
    'Costas',
    'Ombros',
    'Braços',
    'Pernas',
    'Cardio',
    'Full body',
  ]);
  const [foco, setFoco] = useState('Peito');
  const [titulo, setTitulo] = useState('');
  const [minutos, setMinutos] = useState('45');
  const [catalogo, setCatalogo] = useState<ExercicioCatalogo[]>([]);
  const [selecionados, setSelecionados] = useState<Draft[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  const carregarCatalogo = useCallback(async (grupo: string) => {
    const data = await fetchCatalogoExercicios(grupo);
    setFocos(data.focos.length ? data.focos : focos);
    setCatalogo(data.exercicios);
  }, [focos]);

  useEffect(() => {
    if (!visible) return;
    setErro(null);
    setCarregando(true);
    if (treinoExistente) {
      setFoco(treinoExistente.foco);
      setTitulo(treinoExistente.titulo);
      setMinutos(String(treinoExistente.minutos));
      setSelecionados(
        (treinoExistente.itens ?? []).map((i, idx) => ({
          key: `${i.exercicio_chave}-${idx}`,
          chave: i.exercicio_chave,
          nome: i.nome,
          icone: i.icone,
          series: i.series,
          reps: i.reps,
          carga_kg: i.carga_kg,
        })),
      );
    } else {
      setFoco('Peito');
      setTitulo('');
      setMinutos('45');
      setSelecionados([]);
    }
    void (async () => {
      try {
        await carregarCatalogo(treinoExistente?.foco ?? 'Peito');
      } catch (e) {
        setErro(e instanceof Error ? e.message : 'Erro ao carregar.');
      } finally {
        setCarregando(false);
      }
    })();
  }, [visible, treinoExistente, carregarCatalogo]);

  const adicionar = (ex: ExercicioCatalogo) => {
    if (selecionados.some((s) => s.chave === ex.chave)) return;
    setSelecionados((atual) => [
      ...atual,
      {
        key: `${ex.chave}-${Date.now()}`,
        chave: ex.chave,
        nome: ex.nome,
        icone: ex.icone,
        series: ex.series_padrao,
        reps: ex.reps_padrao,
        carga_kg: ex.carga_padrao,
      },
    ]);
  };

  const salvar = async () => {
    if (!selecionados.length) {
      setErro('Adicione pelo menos 1 exercício.');
      return;
    }
    setSalvando(true);
    setErro(null);
    try {
      await criarTreino({
        foco,
        titulo: titulo.trim() || undefined,
        minutos: parseInt(minutos, 10) || 45,
        exercicios: selecionados.map((s) => ({
          exercicio_chave: s.chave,
          series: s.series,
          reps: s.reps,
          carga_kg: s.carga_kg,
        })),
      });
      onSaved();
      onClose();
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Falha ao salvar.');
    } finally {
      setSalvando(false);
    }
  };

  return (
    <Modal visible={visible} animationType="slide" onRequestClose={onClose}>
      <View style={styles.screen}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.link}>Fechar</Text>
          </TouchableOpacity>
          <Text style={styles.titulo}>Novo treino</Text>
          <TouchableOpacity onPress={() => void salvar()} disabled={salvando}>
            <Text style={[styles.link, { color: C.laranja }]}>
              {salvando ? '...' : 'Salvar'}
            </Text>
          </TouchableOpacity>
        </View>

        {carregando ? (
          <ActivityIndicator color="#fff" style={{ marginTop: 40 }} />
        ) : (
          <ScrollView contentContainerStyle={{ padding: 16, gap: 16 }}>
            {erro ? <Text style={styles.erro}>{erro}</Text> : null}

            <Text style={styles.secao}>FOCO</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                {focos.map((f) => (
                  <TouchableOpacity
                    key={f}
                    onPress={() => {
                      setFoco(f);
                      void carregarCatalogo(f);
                    }}
                    style={[
                      styles.chip,
                      foco === f && {
                        borderColor: C.primario,
                        backgroundColor: 'rgba(232,120,48,0.28)',
                      },
                    ]}
                  >
                    <Text style={styles.chipTexto}>{f}</Text>
                  </TouchableOpacity>
                ))}
              </View>
            </ScrollView>

            <TextInput
              style={styles.input}
              placeholder="Título (opcional)"
              placeholderTextColor="rgba(255,255,255,0.35)"
              value={titulo}
              onChangeText={setTitulo}
            />
            <TextInput
              style={styles.input}
              placeholder="Minutos"
              placeholderTextColor="rgba(255,255,255,0.35)"
              keyboardType="number-pad"
              value={minutos}
              onChangeText={setMinutos}
            />

            <Text style={styles.secao}>SEU TREINO ({selecionados.length})</Text>
            {selecionados.map((item) => (
              <View key={item.key} style={styles.card}>
                <View style={styles.row}>
                  <Text style={{ fontSize: 20 }}>{item.icone}</Text>
                  <Text style={styles.nome}>{item.nome}</Text>
                  <TouchableOpacity
                    onPress={() =>
                      setSelecionados((a) => a.filter((x) => x.key !== item.key))
                    }
                  >
                    <Text style={styles.link}>Remover</Text>
                  </TouchableOpacity>
                </View>
                <View style={styles.row}>
                  <Stepper
                    label="Séries"
                    value={item.series}
                    onChange={(v) =>
                      setSelecionados((a) =>
                        a.map((x) =>
                          x.key === item.key ? { ...x, series: v } : x,
                        ),
                      )
                    }
                    min={1}
                    max={10}
                  />
                  <Stepper
                    label="Reps"
                    value={item.reps}
                    onChange={(v) =>
                      setSelecionados((a) =>
                        a.map((x) =>
                          x.key === item.key ? { ...x, reps: v } : x,
                        ),
                      )
                    }
                    min={1}
                    max={50}
                  />
                  <Stepper
                    label="Kg"
                    value={item.carga_kg}
                    onChange={(v) =>
                      setSelecionados((a) =>
                        a.map((x) =>
                          x.key === item.key ? { ...x, carga_kg: v } : x,
                        ),
                      )
                    }
                    min={0}
                    max={300}
                  />
                </View>
              </View>
            ))}

            <Text style={styles.secao}>BIBLIOTECA</Text>
            {catalogo.map((ex) => (
              <TouchableOpacity
                key={ex.chave}
                style={styles.card}
                onPress={() => adicionar(ex)}
              >
                <View style={styles.row}>
                  <Text style={{ fontSize: 20 }}>{ex.icone}</Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.nome}>{ex.nome}</Text>
                    <Text style={styles.sub}>
                      {ex.series_padrao}×{ex.reps_padrao} · {ex.carga_padrao} kg
                    </Text>
                  </View>
                  <Text style={{ color: C.laranja, fontSize: 22 }}>+</Text>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
        )}
      </View>
    </Modal>
  );
}

function Stepper({
  label,
  value,
  onChange,
  min,
  max,
}: {
  label: string;
  value: number;
  onChange: (v: number) => void;
  min: number;
  max: number;
}) {
  return (
    <View style={styles.stepper}>
      <Text style={styles.sub}>{label}</Text>
      <View style={styles.row}>
        <TouchableOpacity onPress={() => onChange(Math.max(min, value - 1))}>
          <Text style={styles.stepBtn}>-</Text>
        </TouchableOpacity>
        <Text style={styles.stepVal}>{value}</Text>
        <TouchableOpacity onPress={() => onChange(Math.min(max, value + 1))}>
          <Text style={styles.stepBtn}>+</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

type IniciarProps = {
  visible: boolean;
  treinoId: number | null;
  onClose: () => void;
  onDone: () => void;
};

export function IniciarTreinoModal({
  visible,
  treinoId,
  onClose,
  onDone,
}: IniciarProps) {
  const [treino, setTreino] = useState<AcademiaTreino | null>(null);
  const [salvando, setSalvando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  useEffect(() => {
    if (!visible || !treinoId) return;
    void (async () => {
      try {
        setTreino(await fetchTreino(treinoId));
      } catch (e) {
        setErro(e instanceof Error ? e.message : 'Erro');
      }
    })();
  }, [visible, treinoId]);

  const toggle = async (item: AcademiaTreinoExercicio) => {
    if (!treinoId || !item.id) return;
    try {
      await toggleTreinoExercicio(treinoId, item.id);
      setTreino((t) =>
        t
          ? {
              ...t,
              itens: (t.itens ?? []).map((i) =>
                i.id === item.id ? { ...i, concluido: !i.concluido } : i,
              ),
            }
          : t,
      );
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro');
    }
  };

  const concluir = async () => {
    if (!treinoId) return;
    setSalvando(true);
    try {
      await concluirTreino(treinoId);
      onDone();
      onClose();
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro');
    } finally {
      setSalvando(false);
    }
  };

  return (
    <Modal visible={visible} animationType="slide" onRequestClose={onClose}>
      <View style={styles.screen}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.link}>Fechar</Text>
          </TouchableOpacity>
          <Text style={styles.titulo}>Treino</Text>
          <View style={{ width: 50 }} />
        </View>
        {!treino ? (
          <ActivityIndicator color="#fff" style={{ marginTop: 40 }} />
        ) : (
          <>
            <ScrollView contentContainerStyle={{ padding: 16, gap: 12 }}>
              {erro ? <Text style={styles.erro}>{erro}</Text> : null}
              <Text style={styles.nomeGrande}>{treino.titulo}</Text>
              <Text style={styles.sub}>
                {treino.foco} · {treino.exercicios} exercícios · ~{treino.minutos}{' '}
                min · +{treino.xp} XP
              </Text>
              {(treino.itens ?? []).map((item) => (
                <TouchableOpacity
                  key={`${item.id}-${item.exercicio_chave}`}
                  style={[
                    styles.card,
                    item.concluido && {
                      backgroundColor: 'rgba(232,120,48,0.18)',
                    },
                  ]}
                  onPress={() => void toggle(item)}
                >
                  <View style={styles.row}>
                    <Text style={{ color: item.concluido ? C.verde : '#666', fontSize: 22 }}>
                      {item.concluido ? '✓' : '○'}
                    </Text>
                    <Text style={{ fontSize: 20 }}>{item.icone}</Text>
                    <View style={{ flex: 1 }}>
                      <Text style={styles.nome}>{item.nome}</Text>
                      <Text style={styles.sub}>
                        {item.series}×{item.reps} · {item.carga_kg} kg
                      </Text>
                    </View>
                  </View>
                </TouchableOpacity>
              ))}
            </ScrollView>
            <TouchableOpacity
              style={styles.cta}
              onPress={() => void concluir()}
              disabled={salvando}
            >
              <Text style={styles.ctaTexto}>
                {salvando
                  ? 'Salvando...'
                  : `Concluir treino · +${treino.xp} XP`}
              </Text>
            </TouchableOpacity>
          </>
        )}
      </View>
    </Modal>
  );
}

type HistProps = {
  visible: boolean;
  onClose: () => void;
};

export function HistoricoTreinosModal({ visible, onClose }: HistProps) {
  const [lista, setLista] = useState<AcademiaTreino[]>([]);

  useEffect(() => {
    if (!visible) return;
    void (async () => {
      try {
        setLista(await fetchHistoricoTreinos());
      } catch {
        setLista([]);
      }
    })();
  }, [visible]);

  return (
    <Modal visible={visible} animationType="slide" onRequestClose={onClose}>
      <View style={styles.screen}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose}>
            <Text style={styles.link}>Fechar</Text>
          </TouchableOpacity>
          <Text style={styles.titulo}>Histórico</Text>
          <View style={{ width: 50 }} />
        </View>
        <ScrollView contentContainerStyle={{ padding: 16, gap: 10 }}>
          {lista.length === 0 ? (
            <Text style={styles.sub}>Nenhum treino no histórico ainda.</Text>
          ) : (
            lista.map((t) => (
              <View key={t.id} style={styles.card}>
                <Text style={styles.nome}>{t.titulo}</Text>
                <Text style={styles.sub}>
                  {t.foco} · {t.exercicios} ex. · {t.minutos} min · +{t.xp} XP
                </Text>
                {t.concluido_em ? (
                  <Text style={{ color: C.verde, fontSize: 12, marginTop: 4 }}>
                    Concluído
                  </Text>
                ) : t.ativo ? (
                  <Text style={{ color: C.laranja, fontSize: 12, marginTop: 4 }}>
                    Ativo
                  </Text>
                ) : null}
              </View>
            ))
          )}
        </ScrollView>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: C.bg },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: 56,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: C.borda,
  },
  titulo: { color: '#FFF', fontSize: 17, fontWeight: '700' },
  link: { color: 'rgba(255,255,255,0.65)', fontWeight: '600', fontSize: 15 },
  secao: {
    color: C.label,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1,
  },
  chip: {
    borderWidth: 1,
    borderColor: C.borda,
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 9,
  },
  chipTexto: { color: '#FFF', fontWeight: '600', fontSize: 13 },
  input: {
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: C.borda,
    paddingHorizontal: 14,
    paddingVertical: 12,
    color: '#FFF',
    fontSize: 15,
  },
  card: {
    backgroundColor: C.card,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 12,
    gap: 10,
  },
  row: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  nome: { color: '#FFF', fontSize: 15, fontWeight: '600', flex: 1 },
  nomeGrande: { color: '#FFF', fontSize: 22, fontWeight: '700' },
  sub: { color: C.label, fontSize: 12 },
  erro: { color: '#F87171', fontSize: 13 },
  stepper: { flex: 1, alignItems: 'center', gap: 4 },
  stepBtn: { color: '#FFF', fontSize: 18, fontWeight: '700', paddingHorizontal: 8 },
  stepVal: { color: '#FFF', fontWeight: '700', minWidth: 24, textAlign: 'center' },
  cta: {
    margin: 16,
    backgroundColor: C.primario,
    borderRadius: 16,
    paddingVertical: 16,
    alignItems: 'center',
  },
  ctaTexto: { color: '#FFF', fontWeight: '700', fontSize: 16 },
});
