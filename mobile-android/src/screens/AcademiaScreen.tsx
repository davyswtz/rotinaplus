import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  useWindowDimensions,
} from 'react-native';
import { getLayoutDashboard } from '../theme/layout';
import {
  excluirEsporteSessao,
  fetchAcademia,
  registrarEsporte,
  toggleAcademiaDia,
} from '../services/rotinaApi';
import type {
  AcademiaData,
  AcademiaTreino,
  AcademiaVolume,
  EsporteCatalogo,
  EsporteResumo,
  EsporteSessao,
} from '../types';
import { CacheKeys, loadCache } from '../offline/store';
import {
  HistoricoTreinosModal,
  IniciarTreinoModal,
  NovoTreinoModal,
} from './NovoTreinoScreen';

// MARK: - Modelos

export type DiaSemanaTreino = {
  id: number;
  label: string;
  foco: string;
  concluido: boolean;
  isRest: boolean;
};

export type VolumeDia = {
  id: string;
  label: string;
  kg: number;
};

const C = {
  roxo: '#E87830',
  laranja: '#FF9B4A',
  verde: '#4ADE80',
  card: 'rgba(255,255,255,0.055)',
  borda: 'rgba(255,255,255,0.07)',
  label: 'rgba(255,255,255,0.42)',
  labelMuted: 'rgba(255,255,255,0.32)',
  historicoFundo: '#4D1F1A',
  ctaMid: '#47171A',
  diaAtivoFundo: 'rgba(232,120,48,0.28)',
  diaAtivoBorda: 'rgba(232,120,48,0.55)',
  diaInativoBorda: 'rgba(255,255,255,0.12)',
};

// MARK: - Stats Academia

function StatsAcademia({
  metaSemana = 0,
  feitos,
  sequencia = 0,
}: {
  metaSemana?: number;
  feitos: number;
  sequencia?: number;
}) {
  const items = [
    { icone: '🏋️', cor: C.laranja, valor: `${metaSemana}x`, label: 'META/SEM' },
    {
      icone: '✓',
      cor: C.verde,
      valor: `${feitos}/${metaSemana}`,
      label: 'FEITOS',
    },
    { icone: '🔥', cor: C.roxo, valor: `${sequencia}`, label: 'SEQ. TREINOS' },
  ];

  return (
    <View style={styles.statsRow}>
      {items.map((item) => (
        <View key={item.label} style={styles.statCard}>
          <Text style={[styles.statIcone, { color: item.cor }]}>{item.icone}</Text>
          <Text style={styles.statValor} numberOfLines={1}>
            {item.valor}
          </Text>
          <Text style={styles.statLabel} numberOfLines={1}>
            {item.label}
          </Text>
        </View>
      ))}
    </View>
  );
}

// MARK: - Esta Semana (clicável)

function EstaSemanaTreino({
  dias,
  onToggle,
}: {
  dias: DiaSemanaTreino[];
  onToggle: (id: number) => void;
}) {
  return (
    <View style={styles.semanaCard}>
      <Text style={styles.secaoLabel}>ESTA SEMANA</Text>
      <View style={styles.semanaRow}>
        {dias.map((dia) => (
          <Pressable
            key={dia.id}
            onPress={() => onToggle(dia.id)}
            style={({ pressed }) => [
              styles.diaCol,
              dia.concluido ? styles.diaColAtivo : styles.diaColInativo,
              pressed && { opacity: 0.85 },
            ]}
          >
            <Text
              style={[
                styles.diaLabel,
                { color: dia.concluido ? '#FFF' : C.labelMuted },
              ]}
            >
              {dia.label}
            </Text>

            <View
              style={[
                styles.diaCirculo,
                dia.concluido ? styles.diaCirculoFeito : styles.diaCirculoVazio,
              ]}
            >
              <Text
                style={[
                  styles.diaIcone,
                  !dia.concluido && { color: 'rgba(255,255,255,0.28)' },
                ]}
              >
                {dia.concluido ? '✓' : dia.isRest ? '☾' : '🏋'}
              </Text>
            </View>

            <Text
              style={[
                styles.diaFoco,
                {
                  color: dia.concluido
                    ? 'rgba(255,255,255,0.75)'
                    : C.labelMuted,
                },
              ]}
              numberOfLines={1}
            >
              {dia.foco}
            </Text>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

// MARK: - CTA Treino de hoje

function CardTreinoHoje({
  foco,
  exercicios,
  minutos,
  xp,
  onIniciar,
  onBiblioteca,
}: {
  foco: string;
  exercicios: number;
  minutos: number;
  xp: number;
  onIniciar?: () => void;
  onBiblioteca?: () => void;
}) {
  return (
    <View style={styles.treinoHoje}>
      <View style={styles.treinoHeader}>
        <Text style={styles.treinoTitulo} numberOfLines={1}>
          Treino de hoje — {foco}
        </Text>
        <TouchableOpacity onPress={onBiblioteca} activeOpacity={0.8}>
          <Text style={styles.biblioteca}>Biblioteca</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity
        style={styles.ctaCard}
        onPress={onIniciar}
        activeOpacity={0.9}
      >
        <View style={styles.ctaEmojiWrap}>
          <Text style={styles.ctaEmoji}>🔥</Text>
        </View>
        <View style={styles.ctaTexto}>
          <Text style={styles.ctaTitulo} numberOfLines={1}>
            Iniciar treino de {foco}
          </Text>
          <Text style={styles.ctaSub} numberOfLines={1}>
            {exercicios} exercícios · ~{minutos} min · +{xp} XP
          </Text>
        </View>
        <Text style={styles.ctaPlay}>▷</Text>
      </TouchableOpacity>
    </View>
  );
}

// MARK: - Volume Semanal

function VolumeSemanalChart({ volumes }: { volumes: VolumeDia[] }) {
  const maxKg = Math.max(...volumes.map((v) => v.kg), 1);

  return (
    <View style={styles.volumeCard}>
      <Text style={styles.secaoLabel}>VOLUME SEMANAL (KG)</Text>
      <View style={styles.volumeRow}>
        {volumes.map((dia) => {
          const altura = dia.kg > 0 ? (dia.kg / maxKg) * 88 : 0;
          return (
            <View key={dia.id} style={styles.volumeCol}>
              {dia.kg > 0 ? (
                <View
                  style={[
                    styles.barra,
                    { height: altura, backgroundColor: C.roxo },
                  ]}
                />
              ) : (
                <View style={{ flex: 1 }} />
              )}
              <Text style={styles.volumeLabel}>{dia.label}</Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

// MARK: - Atalhos Academia

function AtalhosAcademia({
  onNovo,
  onHistorico,
}: {
  onNovo?: () => void;
  onHistorico?: () => void;
}) {
  return (
    <View style={styles.atalhosRow}>
      <TouchableOpacity style={styles.atalhoCard} onPress={onNovo} activeOpacity={0.85}>
        <View style={[styles.atalhoIcone, { backgroundColor: 'rgba(232,120,48,0.18)' }]}>
          <Text style={{ color: C.roxo, fontSize: 20, fontWeight: '700' }}>+</Text>
        </View>
        <Text style={styles.atalhoTitulo}>Novo treino</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.atalhoCard}
        onPress={onHistorico}
        activeOpacity={0.85}
      >
        <View style={[styles.atalhoIcone, { backgroundColor: 'rgba(255,140,51,0.18)' }]}>
          <Text style={{ color: C.laranja, fontSize: 16 }}>☰</Text>
        </View>
        <Text style={styles.atalhoTitulo}>Histórico</Text>
      </TouchableOpacity>
    </View>
  );
}

// MARK: - Outros esportes

function OutrosEsportesSection({
  esportes,
  resumo,
  sessoes,
  onSelecionar,
  onExcluir,
}: {
  esportes: EsporteCatalogo[];
  resumo: EsporteResumo;
  sessoes: EsporteSessao[];
  onSelecionar: (e: EsporteCatalogo) => void;
  onExcluir: (s: EsporteSessao) => void;
}) {
  return (
    <View style={styles.esporteCard}>
      <Text style={styles.secaoLabel}>OUTROS ESPORTES</Text>
      <Text style={styles.esporteHint}>
        Registre corrida, natação, vôlei e mais
      </Text>
      <View style={styles.esporteStats}>
        <View style={styles.esporteMini}>
          <Text style={styles.esporteMiniValor}>{resumo.total_semana}</Text>
          <Text style={styles.esporteMiniLabel}>SESSÕES</Text>
        </View>
        <View style={styles.esporteMini}>
          <Text style={styles.esporteMiniValor}>{resumo.minutos_semana}m</Text>
          <Text style={styles.esporteMiniLabel}>TEMPO</Text>
        </View>
        <View style={styles.esporteMini}>
          <Text style={styles.esporteMiniValor}>+{resumo.xp_semana}</Text>
          <Text style={styles.esporteMiniLabel}>XP</Text>
        </View>
      </View>

      <View style={styles.esporteGrid}>
        {esportes.map((esporte) => (
          <TouchableOpacity
            key={esporte.chave}
            style={styles.esporteItem}
            onPress={() => onSelecionar(esporte)}
            activeOpacity={0.85}
          >
            <Text style={styles.esporteIcone}>{esporte.icone}</Text>
            <Text style={styles.esporteNome} numberOfLines={1}>
              {esporte.nome}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {sessoes.length > 0 ? (
        <>
          <Text style={[styles.secaoLabel, { marginTop: 4 }]}>RECENTES</Text>
          {sessoes.slice(0, 6).map((sessao) => {
            const partes = [`${sessao.minutos} min`];
            if (sessao.distancia_metros && sessao.distancia_metros > 0) {
              partes.push(`${(sessao.distancia_metros / 1000).toFixed(1)} km`);
            }
            if (sessao.data) partes.push(sessao.data);
            return (
              <View key={sessao.id} style={styles.sessaoRow}>
                <Text style={{ fontSize: 20 }}>{sessao.icone}</Text>
                <View style={{ flex: 1, gap: 2 }}>
                  <Text style={styles.sessaoNome}>{sessao.nome}</Text>
                  <Text style={styles.sessaoSub}>{partes.join(' · ')}</Text>
                </View>
                <Text style={styles.sessaoXp}>+{sessao.xp} XP</Text>
                <TouchableOpacity onPress={() => onExcluir(sessao)} hitSlop={8}>
                  <Text style={styles.sessaoLixo}>⌫</Text>
                </TouchableOpacity>
              </View>
            );
          })}
        </>
      ) : null}
    </View>
  );
}

function RegistrarEsporteModal({
  esporte,
  onFechar,
  onSalvar,
}: {
  esporte: EsporteCatalogo;
  onFechar: () => void;
  onSalvar: (p: {
    minutos: number;
    distancia_metros?: number | null;
    nota?: string | null;
  }) => Promise<void>;
}) {
  const [minutos, setMinutos] = useState(String(esporte.minutos_padrao));
  const [distanciaKm, setDistanciaKm] = useState('');
  const [nota, setNota] = useState('');
  const [salvando, setSalvando] = useState(false);

  return (
    <View style={styles.modalWrap}>
      <View style={styles.modalCard}>
        <Text style={styles.modalTitulo}>
          {esporte.icone} {esporte.nome}
        </Text>
        <Text style={styles.modalDesc}>{esporte.descricao}</Text>
        <TextInput
          style={styles.input}
          placeholder="Minutos"
          placeholderTextColor="rgba(255,255,255,0.35)"
          keyboardType="number-pad"
          value={minutos}
          onChangeText={setMinutos}
        />
        {esporte.usa_distancia ? (
          <TextInput
            style={styles.input}
            placeholder="Distância (km)"
            placeholderTextColor="rgba(255,255,255,0.35)"
            keyboardType="decimal-pad"
            value={distanciaKm}
            onChangeText={setDistanciaKm}
          />
        ) : null}
        <TextInput
          style={styles.input}
          placeholder="Nota (opcional)"
          placeholderTextColor="rgba(255,255,255,0.35)"
          value={nota}
          onChangeText={setNota}
        />
        <View style={styles.modalActions}>
          <TouchableOpacity onPress={onFechar}>
            <Text style={styles.link}>Cancelar</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.botaoSalvar}
            disabled={salvando}
            onPress={() => {
              void (async () => {
                setSalvando(true);
                const mins = Math.max(5, parseInt(minutos, 10) || esporte.minutos_padrao);
                let distancia: number | null = null;
                if (esporte.usa_distancia && distanciaKm.trim()) {
                  const km = parseFloat(distanciaKm.replace(',', '.'));
                  if (!Number.isNaN(km)) distancia = Math.round(km * 1000);
                }
                await onSalvar({
                  minutos: mins,
                  distancia_metros: distancia,
                  nota: nota.trim() || null,
                });
                setSalvando(false);
              })();
            }}
          >
            <Text style={styles.botaoSalvarTexto}>
              {salvando ? '...' : 'Salvar'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

// MARK: - Tela Academia

type Props = {
  onHistorico?: () => void;
  onBiblioteca?: () => void;
  onIniciarTreino?: () => void;
  onNovoTreino?: () => void;
};

/** Tela Academia — espelha TelaAcademia.swift + Figma */
export function AcademiaScreen({
  onHistorico,
  onBiblioteca,
  onIniciarTreino,
  onNovoTreino,
}: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const pad = layout.paddingHorizontal;
  const gap = layout.gapSecao;
  const [dias, setDias] = useState<DiaSemanaTreino[]>([]);
  const [volumes, setVolumes] = useState<VolumeDia[]>([]);
  const [metaSemana, setMetaSemana] = useState(0);
  const [sequencia, setSequencia] = useState(0);
  const [treino, setTreino] = useState<AcademiaTreino | null>(null);
  const [esportes, setEsportes] = useState<EsporteCatalogo[]>([]);
  const [esporteSessoes, setEsporteSessoes] = useState<EsporteSessao[]>([]);
  const [esporteResumo, setEsporteResumo] = useState<EsporteResumo>({
    total_semana: 0,
    minutos_semana: 0,
    xp_semana: 0,
  });
  const [esporteSelecionado, setEsporteSelecionado] =
    useState<EsporteCatalogo | null>(null);
  const [mostrarNovo, setMostrarNovo] = useState(false);
  const [mostrarHistorico, setMostrarHistorico] = useState(false);
  const [mostrarIniciar, setMostrarIniciar] = useState(false);
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);

  const carregar = useCallback(async () => {
    setErro(null);
    const cached = await loadCache<AcademiaData>(CacheKeys.academia);
    const aplicar = (data: AcademiaData) => {
      setMetaSemana(data.meta_semana);
      setSequencia(data.sequencia_treinos);
      setDias(
        data.dias.map((d) => ({
          id: d.id,
          label: d.label,
          foco: d.foco,
          concluido: d.concluido,
          isRest: d.is_rest,
        })),
      );
      setVolumes(
        data.volumes.map((v: AcademiaVolume) => ({
          id: String(v.id),
          label: v.label,
          kg: v.kg,
        })),
      );
      setTreino(data.treino_hoje);
      setEsportes(data.esportes ?? []);
      setEsporteSessoes(data.esporte_sessoes ?? []);
      setEsporteResumo(
        data.esporte_resumo ?? {
          total_semana: 0,
          minutos_semana: 0,
          xp_semana: 0,
        },
      );
    };
    if (cached) {
      aplicar(cached);
      setCarregando(false);
    }
    try {
      const data = await fetchAcademia();
      aplicar(data);
    } catch (e) {
      if (!cached) {
        setErro(e instanceof Error ? e.message : 'Erro ao carregar academia.');
      }
    } finally {
      setCarregando(false);
    }
  }, []);

  useEffect(() => {
    void carregar();
  }, [carregar]);

  const feitos = useMemo(
    () => dias.filter((d) => d.concluido).length,
    [dias],
  );

  const toggleDia = async (id: number) => {
    const anterior = dias.find((d) => d.id === id);
    const novo = !(anterior?.concluido ?? false);
    setDias((atual) =>
      atual.map((d) => (d.id === id ? { ...d, concluido: novo } : d)),
    );
    if (anterior) {
      setSequencia((s) => Math.max(0, s + (anterior.concluido ? -1 : 1)));
    }
    try {
      await toggleAcademiaDia(id, novo);
    } catch {
      setDias((atual) =>
        atual.map((d) =>
          d.id === id ? { ...d, concluido: !novo } : d,
        ),
      );
      if (anterior) {
        setSequencia((s) => Math.max(0, s + (anterior.concluido ? 1 : -1)));
      }
    }
  };

  if (carregando) {
    return (
      <View style={[styles.flex, { justifyContent: 'center', alignItems: 'center' }]}>
        <ActivityIndicator color="#fff" />
      </View>
    );
  }

  if (erro) {
    return (
      <View style={[styles.flex, { justifyContent: 'center', alignItems: 'center', padding: 24 }]}>
        <Text style={{ color: 'rgba(255,255,255,0.6)', textAlign: 'center' }}>{erro}</Text>
        <TouchableOpacity
          onPress={() => {
            setCarregando(true);
            void carregar();
          }}
          style={{ marginTop: 12 }}
        >
          <Text style={{ color: C.roxo, fontWeight: '600' }}>Tentar de novo</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <ScrollView
      style={styles.flex}
      contentContainerStyle={styles.scroll}
      showsVerticalScrollIndicator={false}
    >
      <View style={[styles.tituloRow, { paddingHorizontal: pad, paddingTop: gap }]}>
        <Text style={[styles.titulo, { fontSize: layout.fonte(30) }]}>Academia</Text>
        <TouchableOpacity
          style={styles.pillHistorico}
          onPress={() => {
            setMostrarHistorico(true);
            onHistorico?.();
          }}
          activeOpacity={0.85}
        >
          <Text style={styles.pillHistoricoTexto}>Histórico</Text>
        </TouchableOpacity>
      </View>

      <View style={{ paddingHorizontal: pad, paddingTop: gap }}>
        <StatsAcademia
          metaSemana={metaSemana}
          feitos={feitos}
          sequencia={sequencia}
        />
      </View>

      <View style={{ paddingHorizontal: pad, paddingTop: gap }}>
        <EstaSemanaTreino dias={dias} onToggle={toggleDia} />
      </View>

      <View style={{ paddingHorizontal: pad, paddingTop: gap + 6 }}>
        {treino ? (
          <CardTreinoHoje
            foco={treino.foco}
            exercicios={treino.exercicios}
            minutos={treino.minutos}
            xp={treino.xp}
            onIniciar={() => {
              setMostrarIniciar(true);
              onIniciarTreino?.();
            }}
            onBiblioteca={() => {
              setMostrarNovo(true);
              onBiblioteca?.();
            }}
          />
        ) : (
          <TouchableOpacity
            style={styles.ctaCard}
            onPress={() => {
              setMostrarNovo(true);
              onNovoTreino?.();
            }}
            activeOpacity={0.85}
          >
            <View style={styles.ctaEmojiWrap}>
              <Text style={{ color: C.laranja, fontSize: 24, fontWeight: '700' }}>+</Text>
            </View>
            <View style={styles.ctaTexto}>
              <Text style={styles.ctaTitulo}>Montar treino do dia</Text>
              <Text style={styles.ctaSub}>Escolha o foco e comece a registrar</Text>
            </View>
          </TouchableOpacity>
        )}
      </View>

      <View style={{ paddingHorizontal: pad, paddingTop: gap }}>
        <OutrosEsportesSection
          esportes={esportes}
          resumo={esporteResumo}
          sessoes={esporteSessoes}
          onSelecionar={setEsporteSelecionado}
          onExcluir={(sessao) => {
            void (async () => {
              try {
                await excluirEsporteSessao(sessao.id);
                await carregar();
              } catch {
                /* ignore */
              }
            })();
          }}
        />
      </View>

      <View style={{ paddingHorizontal: pad, paddingTop: gap }}>
        <VolumeSemanalChart volumes={volumes} />
      </View>

      <View style={{ paddingHorizontal: pad, paddingTop: gap, paddingBottom: 24 }}>
        <AtalhosAcademia
          onNovo={() => {
            setMostrarNovo(true);
            onNovoTreino?.();
          }}
          onHistorico={() => {
            setMostrarHistorico(true);
            onHistorico?.();
          }}
        />
      </View>

      <NovoTreinoModal
        visible={mostrarNovo}
        treinoExistente={treino}
        onClose={() => setMostrarNovo(false)}
        onSaved={() => {
          void carregar();
        }}
      />
      <IniciarTreinoModal
        visible={mostrarIniciar}
        treinoId={treino?.id ?? null}
        onClose={() => setMostrarIniciar(false)}
        onDone={() => {
          void carregar();
        }}
      />
      <HistoricoTreinosModal
        visible={mostrarHistorico}
        onClose={() => setMostrarHistorico(false)}
      />

      <Modal
        visible={!!esporteSelecionado}
        animationType="slide"
        transparent
        onRequestClose={() => setEsporteSelecionado(null)}
      >
        {esporteSelecionado ? (
          <RegistrarEsporteModal
            esporte={esporteSelecionado}
            onFechar={() => setEsporteSelecionado(null)}
            onSalvar={async (payload) => {
              await registrarEsporte({
                esporte_chave: esporteSelecionado.chave,
                ...payload,
              });
              setEsporteSelecionado(null);
              await carregar();
            }}
          />
        ) : null}
      </Modal>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  scroll: { paddingBottom: 8 },
  tituloRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  titulo: {
    color: '#FFF',
    fontWeight: '700',
  },
  pillHistorico: {
    backgroundColor: C.historicoFundo,
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 999,
  },
  pillHistoricoTexto: {
    color: C.laranja,
    fontSize: 13,
    fontWeight: '600',
  },
  statsRow: {
    flexDirection: 'row',
    gap: 10,
  },
  statCard: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: C.card,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: C.borda,
    paddingVertical: 16,
    gap: 6,
  },
  statIcone: { fontSize: 17 },
  statValor: {
    color: '#FFF',
    fontSize: 20,
    fontWeight: '700',
  },
  statLabel: {
    color: C.label,
    fontSize: 9,
    fontWeight: '700',
    letterSpacing: 0.6,
  },
  semanaCard: {
    backgroundColor: C.card,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
    gap: 14,
  },
  secaoLabel: {
    color: C.label,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1,
  },
  semanaRow: {
    flexDirection: 'row',
    gap: 5,
  },
  diaCol: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 2,
    borderRadius: 16,
    gap: 8,
    borderWidth: 1,
  },
  diaColAtivo: {
    backgroundColor: C.diaAtivoFundo,
    borderColor: C.diaAtivoBorda,
  },
  diaColInativo: {
    backgroundColor: 'rgba(255,255,255,0.02)',
    borderColor: C.diaInativoBorda,
  },
  diaCirculo: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  diaCirculoFeito: {
    backgroundColor: C.roxo,
  },
  diaCirculoVazio: {
    backgroundColor: 'rgba(255,255,255,0.04)',
  },
  diaIcone: {
    fontSize: 12,
    color: '#FFF',
    fontWeight: '700',
  },
  diaLabel: {
    fontSize: 10,
    fontWeight: '600',
  },
  diaFoco: {
    fontSize: 8,
    fontWeight: '500',
  },
  treinoHoje: { gap: 12 },
  treinoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 8,
  },
  treinoTitulo: {
    flex: 1,
    color: '#FFF',
    fontSize: 17,
    fontWeight: '700',
  },
  biblioteca: {
    color: C.roxo,
    fontSize: 14,
    fontWeight: '600',
  },
  ctaCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: 18,
    backgroundColor: C.ctaMid,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.06)',
  },
  ctaEmojiWrap: {
    width: 50,
    height: 50,
    borderRadius: 14,
    backgroundColor: 'rgba(0,0,0,0.28)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  ctaEmoji: { fontSize: 24 },
  ctaTexto: { flex: 1, gap: 4 },
  ctaTitulo: {
    color: '#FFF',
    fontSize: 15,
    fontWeight: '700',
  },
  ctaSub: {
    color: 'rgba(255,255,255,0.52)',
    fontSize: 12,
  },
  ctaPlay: {
    color: C.laranja,
    fontSize: 28,
  },
  volumeCard: {
    backgroundColor: C.card,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
    gap: 16,
  },
  volumeRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    height: 110,
    gap: 8,
  },
  volumeCol: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'flex-end',
    gap: 8,
    height: '100%',
  },
  barra: {
    width: '100%',
    borderRadius: 5,
  },
  volumeLabel: {
    color: C.labelMuted,
    fontSize: 10,
    fontWeight: '500',
  },
  atalhosRow: {
    flexDirection: 'row',
    gap: 10,
  },
  atalhoCard: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: C.card,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: C.borda,
    paddingVertical: 18,
    gap: 12,
  },
  atalhoIcone: {
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: 'center',
    justifyContent: 'center',
  },
  atalhoTitulo: {
    color: '#FFF',
    fontSize: 13,
    fontWeight: '600',
  },
  esporteCard: {
    backgroundColor: C.card,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
    gap: 14,
  },
  esporteHint: {
    color: C.labelMuted,
    fontSize: 13,
    fontWeight: '500',
    marginTop: -6,
  },
  esporteStats: {
    flexDirection: 'row',
    gap: 10,
  },
  esporteMini: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 10,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.04)',
    gap: 4,
  },
  esporteMiniValor: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '700',
  },
  esporteMiniLabel: {
    color: C.label,
    fontSize: 9,
    fontWeight: '700',
  },
  esporteGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  esporteItem: {
    width: '31%',
    flexGrow: 1,
    alignItems: 'center',
    paddingVertical: 14,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderWidth: 1,
    borderColor: C.borda,
    gap: 8,
  },
  esporteIcone: { fontSize: 26 },
  esporteNome: {
    color: '#FFF',
    fontSize: 12,
    fontWeight: '600',
  },
  sessaoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 12,
    borderRadius: 14,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  sessaoNome: {
    color: '#FFF',
    fontSize: 14,
    fontWeight: '600',
  },
  sessaoSub: {
    color: C.label,
    fontSize: 12,
  },
  sessaoXp: {
    color: C.roxo,
    fontSize: 12,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
  },
  sessaoLixo: {
    color: 'rgba(255,255,255,0.35)',
    fontSize: 16,
    fontWeight: '600',
  },
  modalWrap: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.55)',
  },
  modalCard: {
    backgroundColor: '#1A1410',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 20,
    gap: 12,
    borderWidth: 1,
    borderColor: C.borda,
  },
  modalTitulo: {
    color: '#FFF',
    fontSize: 18,
    fontWeight: '700',
  },
  modalDesc: {
    color: 'rgba(255,255,255,0.5)',
    fontSize: 13,
    marginBottom: 4,
  },
  input: {
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: C.borda,
    paddingHorizontal: 14,
    paddingVertical: 12,
    color: '#FFF',
    fontSize: 15,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 8,
  },
  link: {
    color: 'rgba(255,255,255,0.55)',
    fontSize: 15,
    fontWeight: '600',
  },
  botaoSalvar: {
    backgroundColor: C.roxo,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 12,
  },
  botaoSalvarTexto: {
    color: '#FFF',
    fontWeight: '700',
    fontSize: 15,
  },
});
