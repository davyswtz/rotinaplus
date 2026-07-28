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
  useWindowDimensions,
} from 'react-native';
import { getLayoutDashboard } from '../theme/layout';
import { cores } from '../theme/colors';
import {
  atualizarHabitoNota,
  criarHabito,
  fetchHabitos,
  toggleHabitoCheckin,
} from '../services/rotinaApi';
import type {
  HabitoItemJournal,
  HabitoJournal,
  HabitoSugestao,
} from '../types';
import type { AbaFooter } from '../components/FooterNavegacao';
import { CacheKeys, loadCache } from '../offline/store';

const C = {
  primario: '#E87830',
  verde: '#4ADE80',
  streak: '#FF8C47',
  card: 'rgba(255,255,255,0.055)',
  borda: 'rgba(255,255,255,0.08)',
  label: 'rgba(255,255,255,0.42)',
};

const AREA_LABEL: Record<string, string> = {
  geral: 'Geral',
  academia: 'Academia',
  financas: 'Finanças',
  estudos: 'Estudos',
  bemestar: 'Bem-estar',
};

const AREA_COR: Record<string, string> = {
  geral: '#E87830',
  academia: '#FF7A47',
  financas: '#59DB85',
  estudos: '#59D9EB',
  bemestar: '#E8B86A',
};

const HUMORES = ['😞', '😕', '😐', '🙂', '😄'];
const ICONES = ['✨', '💧', '🏃', '📚', '💰', '🧘', '✍️', '😴', '📵', '🥗'];
const AREAS = ['geral', 'academia', 'financas', 'estudos', 'bemestar'];

type Props = {
  onAbrirArea?: (aba: AbaFooter) => void;
};

export function DiarioHabitosScreen({ onAbrirArea }: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const pad = layout.paddingHorizontal;
  const gap = layout.gapSecao;

  const [journal, setJournal] = useState<HabitoJournal | null>(null);
  const [dataSel, setDataSel] = useState<string | undefined>();
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);
  const [bonusMsg, setBonusMsg] = useState<string | null>(null);
  const [mostrarCriar, setMostrarCriar] = useState(false);
  const [itemNota, setItemNota] = useState<HabitoItemJournal | null>(null);

  const carregar = useCallback(async (data?: string) => {
    setErro(null);
    const cached = await loadCache<import('../types').HabitoJournal>(
      CacheKeys.habitos(data),
    );
    if (cached) {
      setJournal(cached);
      setDataSel((atual) => atual ?? cached.data);
      setCarregando(false);
    }
    try {
      const j = await fetchHabitos(data);
      setJournal(j);
      setDataSel((atual) => atual ?? j.data);
    } catch (e) {
      if (!cached) {
        setErro(e instanceof Error ? e.message : 'Erro ao carregar diário.');
      }
    } finally {
      setCarregando(false);
    }
  }, []);

  useEffect(() => {
    void carregar();
  }, [carregar]);

  const dataAtual = dataSel ?? journal?.data ?? '';

  const onToggle = async (item: HabitoItemJournal) => {
    try {
      const result = await toggleHabitoCheckin(item.habito.id, {
        data: dataAtual,
        humor: item.checkin?.humor ?? undefined,
        nota: item.checkin?.nota ?? undefined,
        concluida: !item.concluida,
      });
      if (result.bonus_dia?.completo) {
        setBonusMsg(
          `Dia completo! +${result.bonus_dia.moedas} moedas · streak ${result.bonus_dia.streak_dias}🔥`,
        );
      }
      await carregar(dataSel);
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro no check-in.');
    }
  };

  return (
    <ScrollView
      style={styles.root}
      contentContainerStyle={{ paddingBottom: 28 }}
      showsVerticalScrollIndicator={false}
    >
      <View style={[styles.tituloRow, { paddingHorizontal: pad, paddingTop: gap }]}>
        <Text style={styles.titulo}>Diário</Text>
        <TouchableOpacity
          style={styles.pill}
          onPress={() => setMostrarCriar(true)}
          activeOpacity={0.85}
        >
          <Text style={styles.pillTexto}>＋ Novo</Text>
        </TouchableOpacity>
      </View>

      {carregando && !journal ? (
        <ActivityIndicator color="#fff" style={{ marginTop: 40 }} />
      ) : erro && !journal ? (
        <View style={{ paddingHorizontal: pad, marginTop: gap }}>
          <Text style={styles.erro}>{erro}</Text>
          <TouchableOpacity onPress={() => void carregar(dataSel)}>
            <Text style={styles.link}>Tentar de novo</Text>
          </TouchableOpacity>
        </View>
      ) : journal ? (
        <>
          {bonusMsg ? (
            <Text style={[styles.bonus, { paddingHorizontal: pad, marginTop: 10 }]}>
              {bonusMsg}
            </Text>
          ) : null}

          <View style={[styles.statsRow, { paddingHorizontal: pad, marginTop: gap }]}>
            <Stat
              emoji="🔥"
              valor={`${journal.resumo.streak_geral}`}
              label="STREAK"
              cor={C.streak}
            />
            <Stat
              emoji="✅"
              valor={`${journal.resumo.concluidos}/${journal.resumo.total}`}
              label="HOJE"
              cor={C.verde}
            />
            <Stat
              emoji="✨"
              valor={`+${journal.resumo.xp_hoje}`}
              label="XP"
              cor={C.primario}
            />
          </View>

          <View style={{ paddingHorizontal: pad, marginTop: gap }}>
            <View style={styles.card}>
              <Text style={styles.secao}>ÚLTIMOS 7 DIAS</Text>
              <View style={styles.semanaRow}>
                {journal.semana.map((dia) => {
                  const ativo = dia.data === dataAtual;
                  const fill =
                    dia.total === 0
                      ? 'rgba(255,255,255,0.06)'
                      : dia.percentual === 100
                        ? C.verde
                        : dia.percentual >= 50
                          ? 'rgba(232,120,48,0.7)'
                          : dia.percentual > 0
                            ? 'rgba(232,120,48,0.35)'
                            : 'rgba(255,255,255,0.08)';
                  return (
                    <TouchableOpacity
                      key={dia.data}
                      style={[styles.diaChip, ativo && styles.diaChipAtivo]}
                      onPress={() => {
                        setDataSel(dia.data);
                        setCarregando(true);
                        void carregar(dia.data);
                      }}
                      activeOpacity={0.85}
                    >
                      <Text style={[styles.diaLabel, ativo && { color: '#fff' }]}>
                        {dia.label.toUpperCase()}
                      </Text>
                      <View style={[styles.diaCircle, { backgroundColor: fill }]}>
                        <Text style={styles.diaNum}>
                          {dia.percentual === 100 && dia.total > 0 ? '✓' : dia.concluidos}
                        </Text>
                      </View>
                      {dia.data === journal.hoje ? (
                        <View style={styles.hojeDot} />
                      ) : (
                        <View style={{ height: 4 }} />
                      )}
                    </TouchableOpacity>
                  );
                })}
              </View>
            </View>
          </View>

          <Text style={[styles.secao, { paddingHorizontal: pad, marginTop: gap + 4 }]}>
            HÁBITOS DO DIA
          </Text>

          <View style={{ paddingHorizontal: pad, marginTop: 12, gap: 10 }}>
            {journal.itens.length === 0 ? (
              <EmptySugestoes
                sugestoes={journal.sugestoes}
                onPick={async (s) => {
                  await criarHabito({
                    titulo: s.titulo,
                    detalhe: s.detalhe,
                    icone: s.icone,
                    area: s.area,
                  });
                  await carregar(dataSel);
                }}
              />
            ) : (
              journal.itens.map((item) => (
                <HabitoRow
                  key={item.habito.id}
                  item={item}
                  onToggle={() => void onToggle(item)}
                  onNota={() => setItemNota(item)}
                  onArea={() => {
                    if (item.habito.area === 'academia') onAbrirArea?.('academia');
                    if (item.habito.area === 'financas') onAbrirArea?.('financas');
                  }}
                />
              ))
            )}
          </View>
        </>
      ) : null}

      <Modal visible={mostrarCriar} animationType="slide" transparent>
        <CriarModal
          onFechar={() => setMostrarCriar(false)}
          onSalvo={async (payload) => {
            setMostrarCriar(false);
            await criarHabito(payload);
            await carregar(dataSel);
          }}
        />
      </Modal>

      <Modal visible={!!itemNota} animationType="slide" transparent>
        {itemNota ? (
          <NotaModal
            item={itemNota}
            onFechar={() => setItemNota(null)}
            onSalvo={async (nota, humor) => {
              setItemNota(null);
              await atualizarHabitoNota(itemNota.habito.id, {
                data: dataAtual,
                nota,
                humor,
              });
              await carregar(dataSel);
            }}
          />
        ) : null}
      </Modal>
    </ScrollView>
  );
}

function Stat({
  emoji,
  valor,
  label,
  cor,
}: {
  emoji: string;
  valor: string;
  label: string;
  cor: string;
}) {
  return (
    <View style={styles.stat}>
      <Text style={{ fontSize: 16 }}>{emoji}</Text>
      <Text style={[styles.statValor, { color: '#fff' }]}>{valor}</Text>
      <Text style={[styles.statLabel, { color: cor }]}>{label}</Text>
    </View>
  );
}

function HabitoRow({
  item,
  onToggle,
  onNota,
  onArea,
}: {
  item: HabitoItemJournal;
  onToggle: () => void;
  onNota: () => void;
  onArea: () => void;
}) {
  const area = item.habito.area;
  return (
    <View
      style={[
        styles.habitoRow,
        item.concluida && { backgroundColor: '#0F1F17', borderColor: C.verde },
      ]}
    >
      <TouchableOpacity onPress={onToggle} style={styles.check} activeOpacity={0.85}>
        <View
          style={[
            styles.checkCircle,
            { backgroundColor: item.concluida ? C.verde : 'rgba(255,255,255,0.08)' },
          ]}
        >
          <Text style={{ color: '#fff', fontWeight: '700' }}>
            {item.concluida ? '✓' : item.habito.icone}
          </Text>
        </View>
      </TouchableOpacity>
      <View style={{ flex: 1 }}>
        <Text
          style={[
            styles.habitoTitulo,
            item.concluida && { color: 'rgba(255,255,255,0.45)', textDecorationLine: 'line-through' },
          ]}
        >
          {item.habito.titulo}
        </Text>
        <View style={styles.metaRow}>
          <TouchableOpacity onPress={onArea} activeOpacity={0.8}>
            <Text
              style={[
                styles.areaTag,
                {
                  color: AREA_COR[area] ?? C.primario,
                  backgroundColor: `${AREA_COR[area] ?? C.primario}2E`,
                },
              ]}
            >
              {AREA_LABEL[area] ?? area}
            </Text>
          </TouchableOpacity>
          {item.streak > 0 ? (
            <Text style={styles.streakTxt}>🔥 {item.streak}</Text>
          ) : null}
          <Text style={styles.xp}>+{item.habito.xp} XP</Text>
        </View>
        {item.checkin?.nota ? (
          <Text style={styles.nota} numberOfLines={2}>
            {item.checkin.nota}
          </Text>
        ) : null}
      </View>
      <TouchableOpacity onPress={onNota} style={styles.notaBtn} activeOpacity={0.85}>
        <Text style={{ fontSize: 16 }}>📝</Text>
      </TouchableOpacity>
    </View>
  );
}

function EmptySugestoes({
  sugestoes,
  onPick,
}: {
  sugestoes: HabitoSugestao[];
  onPick: (s: HabitoSugestao) => Promise<void>;
}) {
  return (
    <View style={{ gap: 10 }}>
      <Text style={styles.vazio}>Nenhum hábito ainda. Escolha um para começar:</Text>
      {sugestoes.slice(0, 6).map((s) => (
        <TouchableOpacity
          key={s.titulo}
          style={styles.sugestao}
          onPress={() => void onPick(s)}
          activeOpacity={0.85}
        >
          <Text style={{ fontSize: 22 }}>{s.icone}</Text>
          <View style={{ flex: 1 }}>
            <Text style={styles.habitoTitulo}>{s.titulo}</Text>
            <Text style={styles.vazio}>{s.detalhe}</Text>
          </View>
          <Text style={{ color: C.primario, fontSize: 22, fontWeight: '700' }}>+</Text>
        </TouchableOpacity>
      ))}
    </View>
  );
}

function CriarModal({
  onFechar,
  onSalvo,
}: {
  onFechar: () => void;
  onSalvo: (p: {
    titulo: string;
    detalhe?: string;
    icone: string;
    area: string;
  }) => Promise<void>;
}) {
  const [titulo, setTitulo] = useState('');
  const [detalhe, setDetalhe] = useState('');
  const [icone, setIcone] = useState('✨');
  const [area, setArea] = useState('geral');
  const [salvando, setSalvando] = useState(false);

  return (
    <View style={styles.modalWrap}>
      <View style={styles.modalCard}>
        <Text style={styles.modalTitulo}>Novo hábito</Text>
        <TextInput
          style={styles.input}
          placeholder="Título"
          placeholderTextColor="rgba(255,255,255,0.35)"
          value={titulo}
          onChangeText={setTitulo}
        />
        <TextInput
          style={styles.input}
          placeholder="Detalhe (opcional)"
          placeholderTextColor="rgba(255,255,255,0.35)"
          value={detalhe}
          onChangeText={setDetalhe}
        />
        <Text style={styles.secao}>Ícone</Text>
        <View style={styles.iconeRow}>
          {ICONES.map((i) => (
            <TouchableOpacity
              key={i}
              onPress={() => setIcone(i)}
              style={[styles.iconeChip, icone === i && styles.iconeAtivo]}
            >
              <Text style={{ fontSize: 20 }}>{i}</Text>
            </TouchableOpacity>
          ))}
        </View>
        <Text style={[styles.secao, { marginTop: 12 }]}>Área</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {AREAS.map((a) => (
            <TouchableOpacity
              key={a}
              onPress={() => setArea(a)}
              style={[styles.areaChip, area === a && { borderColor: C.primario }]}
            >
              <Text style={{ color: AREA_COR[a], fontWeight: '600', fontSize: 12 }}>
                {AREA_LABEL[a]}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
        <View style={styles.modalActions}>
          <TouchableOpacity onPress={onFechar}>
            <Text style={styles.link}>Cancelar</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.botaoSalvar}
            disabled={titulo.trim().length < 2 || salvando}
            onPress={() => {
              void (async () => {
                setSalvando(true);
                await onSalvo({
                  titulo: titulo.trim(),
                  detalhe: detalhe.trim() || undefined,
                  icone,
                  area,
                });
                setSalvando(false);
              })();
            }}
          >
            <Text style={styles.botaoSalvarTexto}>
              {salvando ? '…' : 'Salvar'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

function NotaModal({
  item,
  onFechar,
  onSalvo,
}: {
  item: HabitoItemJournal;
  onFechar: () => void;
  onSalvo: (nota: string | null, humor: number) => Promise<void>;
}) {
  const [nota, setNota] = useState(item.checkin?.nota ?? '');
  const [humor, setHumor] = useState(item.checkin?.humor ?? 3);

  return (
    <View style={styles.modalWrap}>
      <View style={styles.modalCard}>
        <Text style={styles.modalTitulo}>
          {item.habito.icone} {item.habito.titulo}
        </Text>
        <Text style={styles.vazio}>Como foi?</Text>
        <View style={styles.humorRow}>
          {HUMORES.map((h, i) => (
            <TouchableOpacity key={h} onPress={() => setHumor(i + 1)}>
              <Text style={{ fontSize: 28, opacity: humor === i + 1 ? 1 : 0.35 }}>
                {h}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
        <TextInput
          style={[styles.input, { minHeight: 80, textAlignVertical: 'top' }]}
          placeholder="Nota do diário…"
          placeholderTextColor="rgba(255,255,255,0.35)"
          multiline
          value={nota}
          onChangeText={setNota}
        />
        <View style={styles.modalActions}>
          <TouchableOpacity onPress={onFechar}>
            <Text style={styles.link}>Fechar</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.botaoSalvar}
            onPress={() =>
              void onSalvo(nota.trim() ? nota.trim() : null, humor)
            }
          >
            <Text style={styles.botaoSalvarTexto}>Salvar</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  tituloRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  titulo: { color: '#fff', fontSize: 30, fontWeight: '700' },
  pill: {
    backgroundColor: 'rgba(232,120,48,0.18)',
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 8,
  },
  pillTexto: { color: C.primario, fontWeight: '600', fontSize: 13 },
  bonus: { color: C.verde, fontWeight: '600', fontSize: 13 },
  erro: { color: 'rgba(255,255,255,0.6)' },
  link: { color: C.primario, fontWeight: '600', marginTop: 8 },
  statsRow: { flexDirection: 'row', gap: 10 },
  stat: {
    flex: 1,
    backgroundColor: C.card,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: C.borda,
    paddingVertical: 14,
    alignItems: 'center',
    gap: 6,
  },
  statValor: { fontSize: 18, fontWeight: '700' },
  statLabel: { fontSize: 9, fontWeight: '700', letterSpacing: 0.6 },
  card: {
    backgroundColor: C.card,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
  },
  secao: {
    color: C.label,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1,
    marginBottom: 12,
  },
  semanaRow: { flexDirection: 'row', gap: 6 },
  diaChip: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 10,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: C.borda,
    backgroundColor: 'rgba(255,255,255,0.02)',
  },
  diaChipAtivo: {
    backgroundColor: 'rgba(232,120,48,0.22)',
    borderColor: 'rgba(232,120,48,0.55)',
  },
  diaLabel: { color: C.label, fontSize: 10, fontWeight: '600', marginBottom: 8 },
  diaCircle: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: 'center',
    justifyContent: 'center',
  },
  diaNum: { color: '#fff', fontWeight: '700', fontSize: 12 },
  hojeDot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: C.primario,
    marginTop: 6,
  },
  habitoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    backgroundColor: C.card,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
  },
  check: {},
  checkCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  habitoTitulo: { color: '#fff', fontSize: 16, fontWeight: '600' },
  metaRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 4 },
  areaTag: {
    fontSize: 11,
    fontWeight: '600',
    overflow: 'hidden',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 999,
  },
  streakTxt: { color: C.streak, fontSize: 11, fontWeight: '700' },
  xp: { color: 'rgba(232,120,48,0.85)', fontSize: 11, fontWeight: '700' },
  nota: { color: 'rgba(255,255,255,0.45)', fontSize: 12, marginTop: 4 },
  notaBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(255,255,255,0.06)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  vazio: { color: 'rgba(255,255,255,0.55)', fontSize: 13 },
  sugestao: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    backgroundColor: C.card,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
  },
  modalWrap: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.65)',
    justifyContent: 'flex-end',
  },
  modalCard: {
    backgroundColor: cores.fundoTela,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 20,
    gap: 10,
    maxHeight: '88%',
  },
  modalTitulo: { color: '#fff', fontSize: 20, fontWeight: '700', marginBottom: 4 },
  input: {
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.14)',
    color: '#fff',
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  iconeRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  iconeChip: {
    width: 44,
    height: 44,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconeAtivo: { backgroundColor: 'rgba(232,120,48,0.3)' },
  areaChip: {
    borderWidth: 1,
    borderColor: C.borda,
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 8,
    marginRight: 8,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 12,
  },
  botaoSalvar: {
    backgroundColor: C.primario,
    borderRadius: 12,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  botaoSalvarTexto: { color: '#fff', fontWeight: '700' },
  humorRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 8,
  },
});
