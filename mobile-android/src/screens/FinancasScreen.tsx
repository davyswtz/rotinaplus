import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
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
  atualizarMeta,
  criarMeta,
  criarTransacao,
  excluirTransacao,
  fetchFinancas,
  pluggyConnectToken,
  pluggySincronizar,
  pluggyVincular,
} from '../services/rotinaApi';
import type {
  FinancasCategoria,
  FinancasData,
  FinancasDistribuicao,
  FinancasMeta,
  FinancasPluggy,
  FinancasSerie,
  FinancasTransacao,
} from '../types';

const C = {
  roxo: '#7A42F5',
  verde: '#4ADE80',
  vermelho: '#F25A72',
  card: 'rgba(255,255,255,0.055)',
  borda: 'rgba(255,255,255,0.08)',
  label: 'rgba(255,255,255,0.42)',
  saldoFundo: '#0F3824',
};

function formatarReais(centavos: number, sinal = false): string {
  const abs = Math.abs(centavos);
  const reais = Math.floor(abs / 100);
  const numero = reais.toLocaleString('pt-BR');
  const base = `R$${numero}`;
  if (!sinal) return base;
  if (centavos > 0) return `+${base}`;
  if (centavos < 0) return `-${base}`;
  return base;
}

function dataCurta(iso: string): string {
  const d = new Date(`${iso}T12:00:00`);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
}

function parseValorCentavos(texto: string): number | null {
  const limpo = texto
    .replace(/R\$/gi, '')
    .replace(/\s/g, '')
    .replace(/\./g, '')
    .replace(',', '.');
  const n = Number(limpo);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.round(n * 100);
}

export function FinancasScreen() {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const [dados, setDados] = useState<FinancasData | null>(null);
  const [mes, setMes] = useState<string | undefined>();
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);
  const [mostrarAdd, setMostrarAdd] = useState(false);
  const [mostrarTx, setMostrarTx] = useState(false);
  const [mostrarMetas, setMostrarMetas] = useState(false);
  const [syncando, setSyncando] = useState(false);
  const [syncMsg, setSyncMsg] = useState<string | null>(null);

  const carregar = useCallback(async (anoMes?: string) => {
    setErro(null);
    try {
      const data = await fetchFinancas(anoMes);
      setDados(data);
      setMes(data.ano_mes);
    } catch (e) {
      setErro(e instanceof Error ? e.message : 'Erro ao carregar finanças.');
    } finally {
      setCarregando(false);
    }
  }, []);

  useEffect(() => {
    setCarregando(true);
    void carregar();
  }, [carregar]);

  const conectarBanco = async () => {
    setSyncando(true);
    setSyncMsg(null);
    try {
      const token = await pluggyConnectToken();
      if (token.mode === 'local') {
        const result = await pluggyVincular('local-sandbox');
        setSyncMsg(`Importadas ${result.importadas} · atualizadas ${result.atualizadas}`);
        await carregar(mes);
      } else {
        Alert.alert(
          'Pluggy configurado',
          'No Android, use o sync após conectar pelo dashboard, ou use o modo local. Para o widget completo, use o iOS ou configure WebView Pluggy.',
        );
        // Fluxo simplificado: se tiver token real, ainda permite sync se já houver item —
        // para sandbox sem widget RN, sugerimos local até integrar WebView.
        setSyncMsg('Defina o widget Pluggy ou use sandbox local.');
      }
    } catch (e) {
      setSyncMsg(e instanceof Error ? e.message : 'Erro ao conectar.');
    } finally {
      setSyncando(false);
    }
  };

  const sincronizar = async () => {
    setSyncando(true);
    setSyncMsg(null);
    try {
      const result = await pluggySincronizar();
      setSyncMsg(`Importadas ${result.importadas} · atualizadas ${result.atualizadas}`);
      await carregar(mes);
    } catch (e) {
      setSyncMsg(e instanceof Error ? e.message : 'Erro ao sincronizar.');
    } finally {
      setSyncando(false);
    }
  };

  const pad = layout.paddingHorizontal;
  const gap = layout.gapSecao;

  return (
    <ScrollView
      style={styles.root}
      contentContainerStyle={{ paddingBottom: 28 }}
      showsVerticalScrollIndicator={false}
    >
      <View style={{ paddingHorizontal: pad, paddingTop: gap }}>
        <View style={styles.tituloRow}>
          <Text style={styles.titulo}>Finanças</Text>
          {dados ? <Text style={styles.mesLabel}>{dados.mes_label}</Text> : null}
        </View>
      </View>

      {carregando && !dados ? (
        <ActivityIndicator color="#FFF" style={{ marginTop: 48 }} />
      ) : erro && !dados ? (
        <View style={{ paddingHorizontal: pad, marginTop: gap }}>
          <Text style={styles.erro}>{erro}</Text>
          <TouchableOpacity onPress={() => void carregar(mes)}>
            <Text style={styles.linkRoxo}>Tentar de novo</Text>
          </TouchableOpacity>
        </View>
      ) : dados ? (
        <>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{
              paddingHorizontal: pad,
              gap: 8,
              paddingTop: gap,
            }}
          >
            {dados.meses.map((m) => {
              const ativo = m.ano_mes === dados.ano_mes;
              return (
                <TouchableOpacity
                  key={m.ano_mes}
                  onPress={() => void carregar(m.ano_mes)}
                  style={[styles.mesChip, ativo && styles.mesChipAtivo]}
                >
                  <Text style={[styles.mesChipTexto, ativo && { color: '#FFF' }]}>
                    {m.curto}
                  </Text>
                </TouchableOpacity>
              );
            })}
          </ScrollView>

          <View style={{ paddingHorizontal: pad, marginTop: gap }}>
            <CardSaldo
              saldo={dados.saldo_centavos}
              receita={dados.receita_centavos}
              gastos={dados.gastos_centavos}
            />
          </View>

          <View style={{ paddingHorizontal: pad, marginTop: gap }}>
            <BancoCard
              pluggy={dados.pluggy}
              syncando={syncando}
              mensagem={syncMsg}
              onConectar={() => void conectarBanco()}
              onSincronizar={() => void sincronizar()}
            />
          </View>

          <View style={[styles.atalhos, { paddingHorizontal: pad, marginTop: gap }]}>
            <Atalho titulo="Transações" icone="📋" onPress={() => setMostrarTx(true)} />
            <Atalho titulo="Adicionar" icone="＋" onPress={() => setMostrarAdd(true)} />
            <Atalho titulo="Metas" icone="🎯" onPress={() => setMostrarMetas(true)} />
          </View>

          <View style={{ paddingHorizontal: pad, marginTop: gap }}>
            <GraficoSerie serie={dados.serie_mensal} />
          </View>

          <View style={{ paddingHorizontal: pad, marginTop: gap }}>
            <DistribuicaoCard itens={dados.distribuicao} />
          </View>

          <View style={{ paddingHorizontal: pad, marginTop: gap }}>
            <View style={styles.recentesHeader}>
              <Text style={styles.recentesTitulo}>Recentes</Text>
              {dados.recentes.length > 0 ? (
                <TouchableOpacity onPress={() => setMostrarTx(true)}>
                  <Text style={styles.linkRoxo}>Ver todas</Text>
                </TouchableOpacity>
              ) : null}
            </View>
            {dados.recentes.length === 0 ? (
              <View>
                <Text style={styles.vazio}>Nenhuma transação neste mês.</Text>
                <TouchableOpacity onPress={() => setMostrarAdd(true)}>
                  <Text style={styles.linkRoxo}>Adicionar primeira transação</Text>
                </TouchableOpacity>
              </View>
            ) : (
              dados.recentes.map((tx) => <LinhaTx key={tx.id} tx={tx} />)
            )}
          </View>

          <Modal visible={mostrarAdd} animationType="slide" transparent>
            <AdicionarModal
              categorias={dados.categorias.despesas}
              receita={dados.categorias.receita}
              onFechar={() => setMostrarAdd(false)}
              onSalvo={() => {
                setMostrarAdd(false);
                void carregar(mes ?? dados.ano_mes);
              }}
            />
          </Modal>

          <Modal visible={mostrarTx} animationType="slide" transparent>
            <ListaTxModal
              transacoes={dados.transacoes}
              onFechar={() => setMostrarTx(false)}
              onExcluir={async (id) => {
                await excluirTransacao(id);
                void carregar(mes ?? dados.ano_mes);
              }}
            />
          </Modal>

          <Modal visible={mostrarMetas} animationType="slide" transparent>
            <MetasModal
              metas={dados.metas}
              onFechar={() => setMostrarMetas(false)}
              onRefresh={() => void carregar(mes ?? dados.ano_mes)}
            />
          </Modal>
        </>
      ) : null}
    </ScrollView>
  );
}

function CardSaldo({
  saldo,
  receita,
  gastos,
}: {
  saldo: number;
  receita: number;
  gastos: number;
}) {
  return (
    <View style={styles.saldoCard}>
      <Text style={styles.saldoLabel}>SALDO DISPONÍVEL</Text>
      <Text style={styles.saldoValor}>{formatarReais(saldo)}</Text>
      <View style={styles.saldoRow}>
        <View>
          <Text style={[styles.miniLabel, { color: C.verde }]}>↑ Receita</Text>
          <Text style={styles.miniValor}>{formatarReais(receita)}</Text>
        </View>
        <View style={{ alignItems: 'flex-end' }}>
          <Text style={[styles.miniLabel, { color: C.vermelho }]}>Gastos ↓</Text>
          <Text style={styles.miniValor}>{formatarReais(gastos)}</Text>
        </View>
      </View>
    </View>
  );
}

function BancoCard({
  pluggy,
  syncando,
  mensagem,
  onConectar,
  onSincronizar,
}: {
  pluggy?: FinancasPluggy;
  syncando: boolean;
  mensagem: string | null;
  onConectar: () => void;
  onSincronizar: () => void;
}) {
  const tem = (pluggy?.conexoes?.length ?? 0) > 0;
  return (
    <View style={styles.card}>
      <Text style={styles.secaoLabel}>BANCO (SANDBOX)</Text>
      <Text style={styles.vazio}>
        {tem
          ? `${pluggy?.conexoes[0]?.connector_name ?? 'Banco'} conectado`
          : 'Conecte o sandbox para importar transações automaticamente.'}
      </Text>
      <View style={{ flexDirection: 'row', gap: 10, marginTop: 10 }}>
        <TouchableOpacity
          style={[styles.botaoSalvar, { flex: 1, alignItems: 'center' }]}
          onPress={onConectar}
          disabled={syncando}
        >
          <Text style={styles.botaoSalvarTexto}>
            {tem ? 'Reconectar' : 'Conectar sandbox'}
          </Text>
        </TouchableOpacity>
        {tem ? (
          <TouchableOpacity
            style={[styles.botaoOutline, { flex: 1 }]}
            onPress={onSincronizar}
            disabled={syncando}
          >
            <Text style={[styles.linkRoxo, { textAlign: 'center' }]}>
              {syncando ? '…' : 'Sincronizar'}
            </Text>
          </TouchableOpacity>
        ) : null}
      </View>
      {mensagem ? (
        <Text style={[styles.vazio, { color: C.verde, marginTop: 8 }]}>{mensagem}</Text>
      ) : null}
      {!pluggy?.configured && pluggy?.local_sandbox ? (
        <Text style={[styles.vazio, { marginTop: 8, fontSize: 11 }]}>
          Modo local ativo (sem chaves Pluggy). Ideal para testar agora.
        </Text>
      ) : null}
    </View>
  );
}

function Atalho({
  titulo,
  icone,
  onPress,
}: {
  titulo: string;
  icone: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity style={styles.atalho} onPress={onPress} activeOpacity={0.85}>
      <View style={styles.atalhoIconeWrap}>
        <Text style={styles.atalhoIcone}>{icone}</Text>
      </View>
      <Text style={styles.atalhoTitulo}>{titulo}</Text>
    </TouchableOpacity>
  );
}

function GraficoSerie({ serie }: { serie: FinancasSerie[] }) {
  const max = useMemo(() => {
    const vals = serie.flatMap((s) => [s.receita_centavos, s.gastos_centavos]);
    return Math.max(...vals, 1);
  }, [serie]);

  return (
    <View style={styles.card}>
      <Text style={styles.secaoLabel}>RECEITA VS GASTOS</Text>
      <View style={styles.chartRow}>
        {serie.map((s) => (
          <View key={s.ano_mes} style={styles.chartCol}>
            <View style={styles.chartBars}>
              <View
                style={[
                  styles.barReceita,
                  { height: Math.max(6, (s.receita_centavos / max) * 88) },
                ]}
              />
              <View
                style={[
                  styles.barGasto,
                  { height: Math.max(4, (s.gastos_centavos / max) * 88) },
                ]}
              />
            </View>
            <Text style={styles.chartLabel}>{s.curto}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

function DistribuicaoCard({ itens }: { itens: FinancasDistribuicao[] }) {
  const total = Math.max(
    itens.reduce((acc, i) => acc + i.valor_centavos, 0),
    1,
  );

  return (
    <View style={styles.card}>
      <Text style={styles.secaoLabel}>DISTRIBUIÇÃO DE GASTOS</Text>
      {itens.length === 0 ? (
        <Text style={styles.vazio}>Nenhuma despesa neste mês.</Text>
      ) : (
        <View style={styles.distRow}>
          <View style={styles.donut}>
            {itens.map((item, idx) => {
              const pct = (item.valor_centavos / total) * 100;
              return (
                <View
                  key={item.categoria}
                  style={[
                    styles.donutSeg,
                    {
                      backgroundColor: item.cor,
                      flex: Math.max(pct, 2),
                      marginLeft: idx === 0 ? 0 : 2,
                    },
                  ]}
                />
              );
            })}
          </View>
          <View style={{ flex: 1, gap: 8 }}>
            {itens.map((item) => (
              <View key={item.categoria} style={styles.legendaRow}>
                <View style={[styles.dot, { backgroundColor: item.cor }]} />
                <Text style={styles.legendaNome} numberOfLines={1}>
                  {item.nome}
                </Text>
                <Text style={styles.legendaValor}>
                  {formatarReais(item.valor_centavos)}
                </Text>
              </View>
            ))}
          </View>
        </View>
      )}
    </View>
  );
}

function LinhaTx({ tx }: { tx: FinancasTransacao }) {
  const receita = tx.tipo === 'receita';
  return (
    <View style={styles.txCard}>
      <View style={styles.txIcone}>
        <Text style={{ fontSize: 20 }}>{tx.icone}</Text>
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.txTitulo}>{tx.titulo}</Text>
        <Text style={styles.txSub}>
          {tx.categoria_nome} · {dataCurta(tx.data)}
        </Text>
      </View>
      <Text style={{ color: receita ? C.verde : C.vermelho, fontWeight: '700' }}>
        {formatarReais(receita ? tx.valor_centavos : -tx.valor_centavos, true)}
      </Text>
    </View>
  );
}

function AdicionarModal({
  categorias,
  receita,
  onFechar,
  onSalvo,
}: {
  categorias: FinancasCategoria[];
  receita: FinancasCategoria;
  onFechar: () => void;
  onSalvo: () => void;
}) {
  const [tipo, setTipo] = useState<'despesa' | 'receita'>('despesa');
  const [categoria, setCategoria] = useState(categorias[0]?.chave ?? 'outros');
  const [titulo, setTitulo] = useState('');
  const [valor, setValor] = useState('');
  const [salvando, setSalvando] = useState(false);

  const salvar = async () => {
    const centavos = parseValorCentavos(valor);
    if (!centavos) {
      Alert.alert('Valor inválido', 'Informe um valor em reais.');
      return;
    }
    if (titulo.trim().length < 2) {
      Alert.alert('Título', 'Informe um título.');
      return;
    }
    setSalvando(true);
    try {
      const hoje = new Date();
      const iso = hoje.toISOString().slice(0, 10);
      const cat = tipo === 'receita' ? 'receita' : categoria;
      const icone =
        tipo === 'receita'
          ? receita.icone
          : categorias.find((c) => c.chave === categoria)?.icone ?? '💳';
      await criarTransacao({
        tipo,
        categoria: cat,
        titulo: titulo.trim(),
        icone,
        valor_centavos: centavos,
        data: iso,
      });
      onSalvo();
    } catch (e) {
      Alert.alert('Erro', e instanceof Error ? e.message : 'Falha ao salvar.');
    } finally {
      setSalvando(false);
    }
  };

  return (
    <View style={styles.modalBackdrop}>
      <View style={styles.modalCard}>
        <Text style={styles.modalTitulo}>Nova transação</Text>
        <View style={styles.segRow}>
          {(['despesa', 'receita'] as const).map((t) => (
            <Pressable
              key={t}
              onPress={() => setTipo(t)}
              style={[styles.seg, tipo === t && styles.segAtivo]}
            >
              <Text style={{ color: '#FFF', fontWeight: '600', textTransform: 'capitalize' }}>
                {t}
              </Text>
            </Pressable>
          ))}
        </View>
        {tipo === 'despesa' ? (
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginBottom: 10 }}>
            {categorias.map((c) => (
              <Pressable
                key={c.chave}
                onPress={() => setCategoria(c.chave)}
                style={[styles.catChip, categoria === c.chave && styles.catChipAtivo]}
              >
                <Text style={{ color: '#FFF' }}>
                  {c.icone} {c.nome}
                </Text>
              </Pressable>
            ))}
          </ScrollView>
        ) : null}
        <TextInput
          placeholder="Título"
          placeholderTextColor={C.label}
          value={titulo}
          onChangeText={setTitulo}
          style={styles.input}
        />
        <TextInput
          placeholder="Valor (R$)"
          placeholderTextColor={C.label}
          value={valor}
          onChangeText={setValor}
          keyboardType="decimal-pad"
          style={styles.input}
        />
        <View style={styles.modalActions}>
          <TouchableOpacity onPress={onFechar}>
            <Text style={styles.linkRoxo}>Cancelar</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.botaoSalvar}
            onPress={() => void salvar()}
            disabled={salvando}
          >
            <Text style={styles.botaoSalvarTexto}>{salvando ? '…' : 'Salvar'}</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

function ListaTxModal({
  transacoes,
  onFechar,
  onExcluir,
}: {
  transacoes: FinancasTransacao[];
  onFechar: () => void;
  onExcluir: (id: number) => Promise<void>;
}) {
  return (
    <View style={styles.modalBackdrop}>
      <View style={[styles.modalCard, { maxHeight: '80%' }]}>
        <Text style={styles.modalTitulo}>Transações</Text>
        <ScrollView>
          {transacoes.length === 0 ? (
            <Text style={styles.vazio}>Nenhuma transação.</Text>
          ) : (
            transacoes.map((tx) => (
              <View key={tx.id}>
                <LinhaTx tx={tx} />
                <TouchableOpacity
                  onPress={() => {
                    Alert.alert('Excluir', `Remover "${tx.titulo}"?`, [
                      { text: 'Cancelar', style: 'cancel' },
                      {
                        text: 'Excluir',
                        style: 'destructive',
                        onPress: () => void onExcluir(tx.id),
                      },
                    ]);
                  }}
                >
                  <Text style={[styles.linkRoxo, { color: C.vermelho, marginBottom: 8 }]}>
                    Excluir
                  </Text>
                </TouchableOpacity>
              </View>
            ))
          )}
        </ScrollView>
        <TouchableOpacity onPress={onFechar} style={{ marginTop: 8 }}>
          <Text style={styles.linkRoxo}>Fechar</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

function MetasModal({
  metas,
  onFechar,
  onRefresh,
}: {
  metas: FinancasMeta[];
  onFechar: () => void;
  onRefresh: () => void;
}) {
  const [titulo, setTitulo] = useState('');
  const [alvo, setAlvo] = useState('');
  const [edicao, setEdicao] = useState<Record<number, string>>({});

  return (
    <View style={styles.modalBackdrop}>
      <View style={[styles.modalCard, { maxHeight: '85%' }]}>
        <Text style={styles.modalTitulo}>Metas</Text>
        <ScrollView>
          {metas.length === 0 ? (
            <Text style={styles.vazio}>Nenhuma meta ainda. Crie a primeira abaixo.</Text>
          ) : (
            metas.map((m) => (
              <View key={m.id} style={styles.metaCard}>
                <Text style={styles.txTitulo}>
                  {m.icone} {m.titulo}
                </Text>
                <Text style={styles.txSub}>
                  {formatarReais(m.valor_atual_centavos)} /{' '}
                  {formatarReais(m.valor_alvo_centavos)} ({Math.round(m.percentual)}%)
                </Text>
                <View style={styles.progressTrack}>
                  <View
                    style={[
                      styles.progressFill,
                      { width: `${Math.min(100, m.percentual)}%` },
                    ]}
                  />
                </View>
                <TextInput
                  placeholder="Valor atual (R$)"
                  placeholderTextColor={C.label}
                  value={
                    edicao[m.id] ??
                    (m.valor_atual_centavos / 100).toFixed(2).replace('.', ',')
                  }
                  onChangeText={(t) => setEdicao((prev) => ({ ...prev, [m.id]: t }))}
                  keyboardType="decimal-pad"
                  style={styles.input}
                />
                <TouchableOpacity
                  onPress={async () => {
                    const texto =
                      edicao[m.id] ??
                      (m.valor_atual_centavos / 100).toFixed(2);
                    const centavos = parseValorCentavos(texto);
                    if (centavos === null && texto.trim() !== '0') {
                      Alert.alert('Valor inválido');
                      return;
                    }
                    await atualizarMeta(m.id, {
                      valor_atual_centavos: centavos ?? 0,
                    });
                    onRefresh();
                  }}
                >
                  <Text style={styles.linkRoxo}>Salvar valor atual</Text>
                </TouchableOpacity>
              </View>
            ))
          )}
        </ScrollView>
        <TextInput
          placeholder="Nova meta"
          placeholderTextColor={C.label}
          value={titulo}
          onChangeText={setTitulo}
          style={styles.input}
        />
        <TextInput
          placeholder="Valor alvo (R$)"
          placeholderTextColor={C.label}
          value={alvo}
          onChangeText={setAlvo}
          keyboardType="decimal-pad"
          style={styles.input}
        />
        <View style={styles.modalActions}>
          <TouchableOpacity onPress={onFechar}>
            <Text style={styles.linkRoxo}>Fechar</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.botaoSalvar}
            onPress={async () => {
              const centavos = parseValorCentavos(alvo);
              if (!centavos || titulo.trim().length < 2) {
                Alert.alert('Dados inválidos');
                return;
              }
              await criarMeta({
                titulo: titulo.trim(),
                icone: '🎯',
                valor_alvo_centavos: centavos,
              });
              setTitulo('');
              setAlvo('');
              onRefresh();
            }}
          >
            <Text style={styles.botaoSalvarTexto}>Criar</Text>
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
    alignItems: 'baseline',
    justifyContent: 'space-between',
  },
  titulo: { color: '#FFF', fontSize: 30, fontWeight: '700' },
  mesLabel: { color: C.label, fontSize: 14, fontWeight: '500' },
  erro: { color: 'rgba(255,255,255,0.6)', marginBottom: 8 },
  linkRoxo: { color: C.roxo, fontWeight: '600', fontSize: 13 },
  mesChip: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 999,
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.borda,
  },
  mesChipAtivo: { backgroundColor: C.roxo, borderColor: C.roxo },
  mesChipTexto: { color: C.label, fontWeight: '600', fontSize: 13 },
  saldoCard: {
    backgroundColor: C.saldoFundo,
    borderRadius: 22,
    padding: 20,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  saldoLabel: {
    color: 'rgba(74,222,128,0.85)',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1,
  },
  saldoValor: { color: '#FFF', fontSize: 36, fontWeight: '700', marginTop: 10 },
  saldoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 14,
  },
  miniLabel: { fontSize: 12, fontWeight: '600' },
  miniValor: { color: '#FFF', fontSize: 16, fontWeight: '700', marginTop: 4 },
  atalhos: { flexDirection: 'row', gap: 10 },
  atalho: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 16,
    borderRadius: 18,
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.borda,
  },
  atalhoIconeWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(122,66,245,0.18)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 10,
  },
  atalhoIcone: { fontSize: 18 },
  atalhoTitulo: { color: '#FFF', fontSize: 12, fontWeight: '600' },
  card: {
    backgroundColor: C.card,
    borderRadius: 20,
    padding: 16,
    borderWidth: 1,
    borderColor: C.borda,
  },
  secaoLabel: {
    color: C.label,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1,
    marginBottom: 14,
  },
  chartRow: { flexDirection: 'row', alignItems: 'flex-end', height: 120 },
  chartCol: { flex: 1, alignItems: 'center' },
  chartBars: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: 3,
    height: 96,
  },
  barReceita: {
    width: 8,
    borderRadius: 4,
    backgroundColor: C.roxo,
  },
  barGasto: {
    width: 8,
    borderRadius: 4,
    backgroundColor: C.vermelho,
    opacity: 0.8,
  },
  chartLabel: { color: C.label, fontSize: 10, marginTop: 8 },
  distRow: { flexDirection: 'row', gap: 14, alignItems: 'center' },
  donut: {
    width: 72,
    height: 72,
    borderRadius: 36,
    overflow: 'hidden',
    flexDirection: 'row',
  },
  donutSeg: { height: '100%' },
  legendaRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  dot: { width: 8, height: 8, borderRadius: 4 },
  legendaNome: { flex: 1, color: 'rgba(255,255,255,0.85)', fontSize: 12 },
  legendaValor: { color: 'rgba(255,255,255,0.7)', fontSize: 12, fontWeight: '600' },
  recentesHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  recentesTitulo: { color: '#FFF', fontSize: 18, fontWeight: '700' },
  vazio: { color: C.label, fontSize: 14, marginVertical: 8 },
  txCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 12,
    borderRadius: 16,
    backgroundColor: C.card,
    borderWidth: 1,
    borderColor: C.borda,
    marginBottom: 8,
  },
  txIcone: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.06)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  txTitulo: { color: '#FFF', fontSize: 15, fontWeight: '600' },
  txSub: { color: C.label, fontSize: 12, marginTop: 3 },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.65)',
    justifyContent: 'flex-end',
  },
  modalCard: {
    backgroundColor: '#161022',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 20,
    borderWidth: 1,
    borderColor: C.borda,
  },
  modalTitulo: { color: '#FFF', fontSize: 20, fontWeight: '700', marginBottom: 14 },
  segRow: { flexDirection: 'row', gap: 8, marginBottom: 12 },
  seg: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 12,
    alignItems: 'center',
    backgroundColor: C.card,
  },
  segAtivo: { backgroundColor: C.roxo },
  catChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
    backgroundColor: C.card,
    marginRight: 8,
  },
  catChipAtivo: { backgroundColor: C.roxo },
  input: {
    backgroundColor: C.card,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: C.borda,
    color: '#FFF',
    paddingHorizontal: 14,
    paddingVertical: 12,
    marginBottom: 10,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 6,
  },
  botaoSalvar: {
    backgroundColor: C.roxo,
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 12,
  },
  botaoSalvarTexto: { color: '#FFF', fontWeight: '700' },
  botaoOutline: {
    borderWidth: 1,
    borderColor: C.roxo,
    borderRadius: 12,
    paddingVertical: 10,
    justifyContent: 'center',
  },
  metaCard: {
    backgroundColor: C.card,
    borderRadius: 14,
    padding: 12,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: C.borda,
  },
  progressTrack: {
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(255,255,255,0.08)',
    marginVertical: 8,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: C.roxo,
  },
});
