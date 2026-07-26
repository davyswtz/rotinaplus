import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Image,
  ImageSourcePropType,
  Modal,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  useWindowDimensions,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { getLayoutDashboard } from '../theme/layout';
import {
  fetchAmigos,
  fetchAmigoStats,
  fetchClasses,
  fetchPerfilStats,
  convidarAmigo,
  removerAmigo,
  updatePerfil,
  type ClasseCatalogItem,
} from '../services/rotinaApi';
import type { Amigo, AmigoStats, Perfil, PerfilSerieDia, PerfilStats } from '../types';
import { avatarAssetKey } from '../types';

const C = {
  primario: '#E87830',
  laranja: '#FF9B4A',
  verde: '#4ADE80',
  falha: '#F26666',
  card: 'rgba(255,255,255,0.055)',
  borda: 'rgba(255,255,255,0.07)',
  label: 'rgba(255,255,255,0.42)',
};

const AVATARES: Record<string, ImageSourcePropType> = {
  guara_serio: require('../assets/avatars/avatar_guara_serio.png'),
  guara_sorriso: require('../assets/avatars/avatar_guara_sorriso.png'),
  guara_sono: require('../assets/avatars/avatar_guara_sono.png'),
  guara_surpreso: require('../assets/avatars/avatar_guara_surpreso.png'),
  bussola: require('../assets/avatars/avatar_bussola.png'),
  mapa_escrevendo: require('../assets/avatars/avatar_mapa_escrevendo.png'),
  corda: require('../assets/avatars/avatar_corda.png'),
  lanterna: require('../assets/avatars/avatar_lanterna.png'),
  mapa_tesouro: require('../assets/avatars/avatar_mapa_tesouro.png'),
  clava: require('../assets/avatars/avatar_clava.png'),
  pergaminho: require('../assets/avatars/avatar_pergaminho.png'),
  bolsa_moedas: require('../assets/avatars/avatar_bolsa_moedas.png'),
  emblema_clavas: require('../assets/avatars/avatar_emblema_clavas.png'),
  escudo: require('../assets/avatars/avatar_escudo.png'),
  map_maker: require('../assets/avatars/avatar_map_maker.png'),
  selo: require('../assets/avatars/avatar_selo.png'),
};

type Props = {
  onPerfilAtualizado?: (p: Perfil) => void;
  onSair?: () => void;
};

export function PerfilScreen({ onPerfilAtualizado, onSair }: Props) {
  const { width } = useWindowDimensions();
  const layout = getLayoutDashboard(width);
  const pad = layout.paddingHorizontal;
  const gap = layout.gapSecao;

  const [stats, setStats] = useState<PerfilStats | null>(null);
  const [periodo, setPeriodo] = useState<'semana' | 'mes'>('semana');
  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState<string | null>(null);
  const [precisaLogin, setPrecisaLogin] = useState(false);
  const [mostrarNome, setMostrarNome] = useState(false);
  const [mostrarAvatar, setMostrarAvatar] = useState(false);
  const [mostrarClasse, setMostrarClasse] = useState(false);
  const [mostrarAddAmigo, setMostrarAddAmigo] = useState(false);
  const [amigoSelecionado, setAmigoSelecionado] = useState<Amigo | null>(null);
  const [amigoStats, setAmigoStats] = useState<AmigoStats | null>(null);
  const [amigoStatsPeriodo, setAmigoStatsPeriodo] = useState<'semana' | 'mes'>('semana');
  const [carregandoAmigoStats, setCarregandoAmigoStats] = useState(false);
  const [erroAmigoStats, setErroAmigoStats] = useState<string | null>(null);
  const [nomeEdit, setNomeEdit] = useState('');
  const [codigoAmigo, setCodigoAmigo] = useState('');
  const [amigos, setAmigos] = useState<Amigo[]>([]);
  const [erroAmigo, setErroAmigo] = useState<string | null>(null);
  const [adicionandoAmigo, setAdicionandoAmigo] = useState(false);
  const [conviteEnviado, setConviteEnviado] = useState(false);

  const carregar = useCallback(async () => {
    setErro(null);
    setPrecisaLogin(false);
    try {
      const [data, lista] = await Promise.all([
        fetchPerfilStats(periodo),
        fetchAmigos().catch(() => null),
      ]);
      setStats(data);
      if (lista) setAmigos(lista.amigos);
      onPerfilAtualizado?.(data.perfil);
    } catch (e) {
      const status = (e as Error & { status?: number })?.status;
      const msg = e instanceof Error ? e.message : 'Erro ao carregar perfil.';
      const unauth =
        status === 401 ||
        status === 403 ||
        /unauthenticated|não autentic|nao autentic|unauthorized/i.test(msg);
      setPrecisaLogin(unauth);
      setErro(unauth ? 'Sessão expirada ou não autenticado.' : msg);
    } finally {
      setCarregando(false);
    }
  }, [periodo, onPerfilAtualizado]);

  useEffect(() => {
    setCarregando(true);
    void carregar();
  }, [carregar]);

  const perfil = stats?.perfil;
  const avatarSrc =
    AVATARES[avatarAssetKey(perfil?.avatar_key ?? 'guara_serio')] ??
    AVATARES.guara_serio;

  const maxStack = useMemo(() => {
    if (!stats) return 1;
    return Math.max(...stats.serie.map((d) => d.acertos + d.falhas), 1);
  }, [stats]);

  const maxXp = useMemo(() => {
    if (!stats) return 1;
    return Math.max(...stats.serie.map((d) => d.xp), 1);
  }, [stats]);

  if (carregando && !stats) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color="#fff" />
      </View>
    );
  }

  if ((erro || precisaLogin) && !stats) {
    return (
      <View style={[styles.center, { paddingHorizontal: 28 }]}>
        <Text style={{ fontSize: 42, marginBottom: 4 }}>🔐</Text>
        <Text style={styles.authTitulo}>
          {precisaLogin ? 'Sessão expirada' : 'Não foi possível carregar o perfil'}
        </Text>
        <Text style={styles.erro}>
          {precisaLogin
            ? 'Faça login novamente para continuar.'
            : erro}
        </Text>
        {precisaLogin ? (
          <TouchableOpacity
            style={styles.botaoLogin}
            onPress={onSair}
            activeOpacity={0.85}
          >
            <Text style={styles.botaoLoginTexto}>Entrar novamente</Text>
          </TouchableOpacity>
        ) : (
          <>
            <TouchableOpacity onPress={() => void carregar()}>
              <Text style={{ color: C.primario, fontWeight: '600' }}>
                Tentar de novo
              </Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={onSair} style={{ marginTop: 8 }}>
              <Text style={{ color: 'rgba(255,255,255,0.65)', fontWeight: '600' }}>
                Entrar novamente
              </Text>
            </TouchableOpacity>
          </>
        )}
      </View>
    );
  }

  if (!stats || !perfil) return null;

  return (
    <ScrollView style={styles.flex} contentContainerStyle={{ paddingBottom: 24 }}>
      <Text style={[styles.titulo, { paddingHorizontal: pad, paddingTop: gap }]}>
        Perfil
      </Text>

      <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
        <View style={styles.heroRow}>
          <Image source={avatarSrc} style={styles.avatar} />
          <View style={{ flex: 1, gap: 4 }}>
            <Text style={styles.nome}>
              {(perfil.nome_heroi || 'herói').toLowerCase()}
            </Text>
            <Text style={styles.nick}>
              Código: {perfil.codigo_amigo || '—'}
            </Text>
            <Text style={styles.classe}>
              {perfil.emoji_classe} {perfil.classe}
            </Text>
            <Text style={styles.sub}>
              Nv. {perfil.nivel} · {perfil.moedas} moedas · {perfil.streak_dias}d
              streak
            </Text>
          </View>
        </View>
      </View>

      <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
        <View style={styles.rowBetween}>
          <Text style={styles.secao}>NÍVEL & EXPERIÊNCIA</Text>
          <Text style={{ color: C.laranja, fontWeight: '700' }}>
            Nv. {stats.nivel.atual}
          </Text>
        </View>
        <View style={styles.xpTrack}>
          <View
            style={[
              styles.xpFill,
              { width: `${Math.min(100, stats.nivel.progresso * 100)}%` },
            ]}
          />
        </View>
        <Text style={styles.sub}>
          {stats.nivel.xp_atual} / {stats.nivel.xp_proximo} XP
        </Text>
      </View>

      <View style={{ flexDirection: 'row', gap: 8, paddingHorizontal: pad, marginTop: gap }}>
        {(['semana', 'mes'] as const).map((p) => (
          <TouchableOpacity
            key={p}
            onPress={() => setPeriodo(p)}
            style={[
              styles.chip,
              periodo === p && {
                borderColor: C.primario,
                backgroundColor: 'rgba(232,120,48,0.28)',
              },
            ]}
          >
            <Text style={styles.chipTexto}>{p === 'semana' ? '7 dias' : '30 dias'}</Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={[styles.statsRow, { paddingHorizontal: pad, marginTop: 12 }]}>
        <Mini valor={`${stats.totais.acertos}`} label="ACERTOS" cor={C.verde} />
        <Mini valor={`${stats.totais.falhas}`} label="FALHAS" cor={C.falha} />
        <Mini valor={`${stats.totais.taxa_sucesso}%`} label="TAXA" cor={C.laranja} />
        <Mini valor={`+${stats.totais.xp_ganho}`} label="XP" cor={C.primario} />
      </View>

      <ChartAcertos
        serie={stats.serie}
        maxY={maxStack}
        pad={pad}
        gap={gap}
      />
      <ChartXp serie={stats.serie} maxY={maxXp} pad={pad} gap={gap} />

      <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
        <Text style={styles.secao}>POR ÁREA</Text>
        <AreaRow
          titulo="🎯 Missões"
          a={stats.por_area.missoes.acertos ?? 0}
          f={stats.por_area.missoes.falhas ?? 0}
          t={stats.por_area.missoes.taxa ?? 0}
        />
        <AreaRow
          titulo="📓 Hábitos"
          a={stats.por_area.habitos.acertos ?? 0}
          f={stats.por_area.habitos.falhas ?? 0}
          t={stats.por_area.habitos.taxa ?? 0}
        />
        <AreaRow
          titulo="🏋️ Academia"
          a={stats.por_area.academia.acertos ?? 0}
          f={stats.por_area.academia.falhas ?? 0}
          t={stats.por_area.academia.taxa ?? 0}
        />
        <Text style={[styles.sub, { marginTop: 8 }]}>
          🏃 Esportes · {stats.por_area.esportes.sessoes ?? 0} sessões ·{' '}
          {stats.por_area.esportes.minutos ?? 0} min
        </Text>
      </View>

      <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
        <View style={styles.rowBetween}>
          <Text style={styles.secao}>AMIGOS</Text>
          <Text style={styles.sub}>{amigos.length}</Text>
        </View>

        {amigos.length === 0 ? (
          <Text style={styles.sub}>
            Nenhum amigo ainda. Envie um pedido pelo código.
          </Text>
        ) : (
          amigos.map((amigo) => {
            const src =
              AVATARES[avatarAssetKey(amigo.avatar_key)] ?? AVATARES.guara_serio;
            return (
              <View key={amigo.id} style={styles.amigoRow}>
                <TouchableOpacity
                  style={{ flex: 1, flexDirection: 'row', alignItems: 'center', gap: 12 }}
                  onPress={() => {
                    setAmigoSelecionado(amigo);
                    setAmigoStats(null);
                    setErroAmigoStats(null);
                    setAmigoStatsPeriodo('semana');
                    setCarregandoAmigoStats(true);
                    void (async () => {
                      try {
                        const data = await fetchAmigoStats(amigo.id, 'semana');
                        setAmigoStats(data);
                      } catch (e) {
                        setErroAmigoStats(
                          e instanceof Error ? e.message : 'Erro ao carregar stats.',
                        );
                      } finally {
                        setCarregandoAmigoStats(false);
                      }
                    })();
                  }}
                >
                  <Image source={src} style={styles.amigoAvatar} />
                  <View style={{ flex: 1 }}>
                    <Text style={styles.amigoNome}>
                      {(amigo.nome_heroi || amigo.codigo_amigo || 'herói').toLowerCase()}
                    </Text>
                    <Text style={styles.sub}>
                      {amigo.codigo_amigo || '—'} · Nv. {amigo.nivel} ·{' '}
                      {amigo.emoji_classe} {amigo.classe}
                    </Text>
                  </View>
                  <Text style={{ color: 'rgba(255,255,255,0.3)', fontSize: 18 }}>›</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => {
                    void (async () => {
                      try {
                        await removerAmigo(amigo.id);
                        setAmigos((prev) => prev.filter((a) => a.id !== amigo.id));
                      } catch {
                        // mantém lista
                      }
                    })();
                  }}
                >
                  <Text style={{ color: C.falha, fontWeight: '700' }}>Remover</Text>
                </TouchableOpacity>
              </View>
            );
          })
        )}

        <TouchableOpacity
          style={styles.botaoAmigo}
          onPress={() => {
            setCodigoAmigo('');
            setErroAmigo(null);
            setConviteEnviado(false);
            setMostrarAddAmigo(true);
          }}
        >
          <Text style={styles.botaoAmigoTexto}>Adicionar amigo</Text>
        </TouchableOpacity>
      </View>

      <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
        <Text style={styles.secao}>EDITAR HERÓI</Text>
        <EditBtn
          titulo="Nome"
          valor={(perfil.nome_heroi || 'herói').toLowerCase()}
          onPress={() => {
            setNomeEdit(perfil.nome_heroi || '');
            setMostrarNome(true);
          }}
        />
        <EditBtn
          titulo="Foto / avatar"
          valor="Trocar imagem"
          onPress={() => setMostrarAvatar(true)}
        />
        <EditBtn
          titulo="Classe"
          valor={`${perfil.emoji_classe} ${perfil.classe}`}
          onPress={() => setMostrarClasse(true)}
        />
      </View>

      <TouchableOpacity
        style={[styles.sair, { marginHorizontal: pad, marginTop: gap }]}
        onPress={onSair}
      >
        <Text style={styles.sairTexto}>Sair da conta</Text>
      </TouchableOpacity>

      <Modal visible={mostrarNome} animationType="slide" transparent>
        <View style={styles.modalWrap}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitulo}>Editar nome</Text>
            <TextInput
              style={styles.input}
              value={nomeEdit}
              onChangeText={setNomeEdit}
              placeholder="Nome do herói"
              placeholderTextColor="rgba(255,255,255,0.35)"
            />
            <View style={styles.modalActions}>
              <TouchableOpacity onPress={() => setMostrarNome(false)}>
                <Text style={styles.link}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={styles.botaoSalvar}
                onPress={() => {
                  void (async () => {
                    const nome = nomeEdit.trim();
                    if (!nome) return;
                    const p = await updatePerfil({ nome_heroi: nome });
                    await AsyncStorage.setItem('nome_heroi', nome);
                    onPerfilAtualizado?.(p);
                    setMostrarNome(false);
                    await carregar();
                  })();
                }}
              >
                <Text style={styles.botaoSalvarTexto}>Salvar</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      <Modal
        visible={amigoSelecionado != null}
        animationType="slide"
        onRequestClose={() => setAmigoSelecionado(null)}
      >
        <View style={styles.screenModal}>
          <View style={styles.headerModal}>
            <TouchableOpacity onPress={() => setAmigoSelecionado(null)}>
              <Text style={styles.link}>Fechar</Text>
            </TouchableOpacity>
            <Text style={styles.modalTitulo}>Stats do amigo</Text>
            <View style={{ width: 50 }} />
          </View>
          <ScrollView contentContainerStyle={{ padding: 16, gap: 14 }}>
            {amigoSelecionado ? (
              <View style={styles.heroRow}>
                <Image
                  source={
                    AVATARES[avatarAssetKey(amigoSelecionado.avatar_key)] ??
                    AVATARES.guara_serio
                  }
                  style={styles.amigoAvatarGrande}
                />
                <View style={{ flex: 1, gap: 4 }}>
                  <Text style={styles.nome}>
                    {(
                      amigoSelecionado.nome_heroi ||
                      amigoSelecionado.codigo_amigo ||
                      'herói'
                    ).toLowerCase()}
                  </Text>
                  <Text style={styles.nick}>
                    {amigoSelecionado.codigo_amigo || '—'} ·{' '}
                    {amigoSelecionado.emoji_classe} {amigoSelecionado.classe}
                  </Text>
                </View>
              </View>
            ) : null}

            <View style={{ flexDirection: 'row', gap: 8 }}>
              {(['semana', 'mes'] as const).map((p) => (
                <TouchableOpacity
                  key={p}
                  onPress={() => {
                    setAmigoStatsPeriodo(p);
                    if (!amigoSelecionado) return;
                    setCarregandoAmigoStats(true);
                    setErroAmigoStats(null);
                    void (async () => {
                      try {
                        const data = await fetchAmigoStats(amigoSelecionado.id, p);
                        setAmigoStats(data);
                      } catch (e) {
                        setErroAmigoStats(
                          e instanceof Error ? e.message : 'Erro ao carregar.',
                        );
                      } finally {
                        setCarregandoAmigoStats(false);
                      }
                    })();
                  }}
                  style={[
                    styles.chip,
                    amigoStatsPeriodo === p && {
                      borderColor: C.primario,
                      backgroundColor: 'rgba(232,120,48,0.28)',
                    },
                  ]}
                >
                  <Text style={styles.chipTexto}>
                    {p === 'semana' ? '7 dias' : '30 dias'}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>

            {carregandoAmigoStats && !amigoStats ? (
              <ActivityIndicator color="#fff" style={{ marginTop: 24 }} />
            ) : erroAmigoStats && !amigoStats ? (
              <Text style={styles.sub}>{erroAmigoStats}</Text>
            ) : amigoStats ? (
              <>
                <View style={styles.card}>
                  <Text style={styles.secao}>NÍVEL</Text>
                  <Text style={{ color: '#FFF', fontWeight: '600' }}>
                    Nv. {amigoStats.nivel.atual} · {amigoStats.nivel.xp_atual}/
                    {amigoStats.nivel.xp_proximo} XP · {amigoStats.nivel.moedas} 🪙
                  </Text>
                  <View style={styles.xpTrack}>
                    <View
                      style={[
                        styles.xpFill,
                        {
                          width: `${Math.min(100, amigoStats.nivel.progresso * 100)}%`,
                        },
                      ]}
                    />
                  </View>
                </View>

                <View style={styles.statsRow}>
                  <Mini
                    valor={`${amigoStats.totais.acertos}`}
                    label="ACERTOS"
                    cor={C.verde}
                  />
                  <Mini
                    valor={`${amigoStats.totais.falhas}`}
                    label="FALHAS"
                    cor={C.falha}
                  />
                  <Mini
                    valor={`${amigoStats.totais.taxa_sucesso}%`}
                    label="TAXA"
                    cor={C.laranja}
                  />
                  <Mini
                    valor={`+${amigoStats.totais.xp_ganho}`}
                    label="XP"
                    cor={C.primario}
                  />
                </View>

                <View style={styles.card}>
                  <Text style={styles.secao}>POR ÁREA</Text>
                  <AreaRow
                    titulo="🎯 Missões"
                    a={amigoStats.por_area.missoes.acertos ?? 0}
                    f={amigoStats.por_area.missoes.falhas ?? 0}
                    t={amigoStats.por_area.missoes.taxa ?? 0}
                  />
                  <AreaRow
                    titulo="📓 Hábitos"
                    a={amigoStats.por_area.habitos.acertos ?? 0}
                    f={amigoStats.por_area.habitos.falhas ?? 0}
                    t={amigoStats.por_area.habitos.taxa ?? 0}
                  />
                  <AreaRow
                    titulo="🏋️ Academia"
                    a={amigoStats.por_area.academia.acertos ?? 0}
                    f={amigoStats.por_area.academia.falhas ?? 0}
                    t={amigoStats.por_area.academia.taxa ?? 0}
                  />
                  <Text style={[styles.sub, { marginTop: 8 }]}>
                    🏃 Esportes · {amigoStats.por_area.esportes.sessoes ?? 0}{' '}
                    sessões · {amigoStats.por_area.esportes.minutos ?? 0} min
                  </Text>
                </View>

                <Text style={styles.sub}>
                  Streak {amigoStats.totais.streak_atual}d ·{' '}
                  {amigoStats.totais.dias_completos} dias completos ·{' '}
                  {amigoStats.totais.sequencia_treinos} treinos em sequência
                </Text>
              </>
            ) : null}
          </ScrollView>
        </View>
      </Modal>

      <Modal visible={mostrarAddAmigo} animationType="slide" transparent>
        <View style={styles.modalWrap}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitulo}>Adicionar amigo</Text>
            <TextInput
              style={styles.input}
              value={codigoAmigo}
              onChangeText={setCodigoAmigo}
              placeholder="ABC123"
              autoCapitalize="characters"
              autoCorrect={false}
              placeholderTextColor="rgba(255,255,255,0.35)"
            />
            {erroAmigo ? (
              <Text style={{ color: C.falha, marginBottom: 8 }}>{erroAmigo}</Text>
            ) : conviteEnviado ? (
              <Text style={{ color: C.verde, marginBottom: 8 }}>
                Solicitação enviada! Seu amigo precisa aceitar nas notificações.
              </Text>
            ) : (
              <Text style={[styles.sub, { marginBottom: 8 }]}>
                Digite o código do herói (aparece no perfil dele).
              </Text>
            )}
            <View style={styles.modalActions}>
              <TouchableOpacity onPress={() => setMostrarAddAmigo(false)}>
                <Text style={styles.link}>Fechar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.botaoSalvar, adicionandoAmigo && { opacity: 0.6 }]}
                disabled={adicionandoAmigo}
                onPress={() => {
                  void (async () => {
                    const codigo = codigoAmigo.trim();
                    if (!codigo) return;
                    setAdicionandoAmigo(true);
                    setErroAmigo(null);
                    setConviteEnviado(false);
                    try {
                      await convidarAmigo(codigo);
                      setConviteEnviado(true);
                    } catch (e) {
                      setErroAmigo(
                        e instanceof Error ? e.message : 'Não foi possível enviar.',
                      );
                    } finally {
                      setAdicionandoAmigo(false);
                    }
                  })();
                }}
              >
                <Text style={styles.botaoSalvarTexto}>
                  {adicionandoAmigo ? '...' : 'Enviar'}
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      <Modal visible={mostrarAvatar} animationType="slide">
        <View style={styles.screenModal}>
          <View style={styles.headerModal}>
            <TouchableOpacity onPress={() => setMostrarAvatar(false)}>
              <Text style={styles.link}>Fechar</Text>
            </TouchableOpacity>
            <Text style={styles.modalTitulo}>Escolher avatar</Text>
            <View style={{ width: 50 }} />
          </View>
          <ScrollView contentContainerStyle={{ padding: 16, flexDirection: 'row', flexWrap: 'wrap', gap: 12 }}>
            {Object.keys(AVATARES).map((key) => (
              <TouchableOpacity
                key={key}
                onPress={() => {
                  void (async () => {
                    const p = await updatePerfil({ avatar_key: key });
                    await AsyncStorage.setItem('avatar_selecionado', `avatar_${key}`);
                    onPerfilAtualizado?.(p);
                    setMostrarAvatar(false);
                    await carregar();
                  })();
                }}
                style={[
                  styles.avatarTile,
                  perfil.avatar_key === key && { borderColor: C.primario },
                ]}
              >
                <Image source={AVATARES[key]} style={{ width: 56, height: 56 }} />
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
      </Modal>

      <Modal visible={mostrarClasse} animationType="slide">
        <ClassePicker
          atual={perfil.classe}
          onClose={() => setMostrarClasse(false)}
          onPick={(c) => {
            void (async () => {
              const p = await updatePerfil({
                classe: c.nome,
                emoji_classe: c.emoji,
              });
              onPerfilAtualizado?.(p);
              setMostrarClasse(false);
              await carregar();
            })();
          }}
        />
      </Modal>
    </ScrollView>
  );
}

function Mini({
  valor,
  label,
  cor,
}: {
  valor: string;
  label: string;
  cor: string;
}) {
  return (
    <View style={[styles.mini, { borderColor: cor + '40' }]}>
      <Text style={styles.miniValor}>{valor}</Text>
      <Text style={styles.miniLabel}>{label}</Text>
    </View>
  );
}

function ChartAcertos({
  serie,
  maxY,
  pad,
  gap,
}: {
  serie: PerfilSerieDia[];
  maxY: number;
  pad: number;
  gap: number;
}) {
  return (
    <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
      <Text style={styles.secao}>ACERTOS × FALHAS</Text>
      <View style={styles.chartRow}>
        {serie.map((d) => (
          <View key={d.data} style={styles.chartCol}>
            <View style={styles.bars}>
              {d.falhas > 0 ? (
                <View
                  style={{
                    height: Math.max(4, (d.falhas / maxY) * 90),
                    backgroundColor: C.falha,
                    borderRadius: 4,
                    width: '100%',
                  }}
                />
              ) : null}
              {d.acertos > 0 ? (
                <View
                  style={{
                    height: Math.max(4, (d.acertos / maxY) * 90),
                    backgroundColor: C.verde,
                    borderRadius: 4,
                    width: '100%',
                    marginTop: 2,
                  }}
                />
              ) : null}
              {d.acertos === 0 && d.falhas === 0 ? (
                <View
                  style={{
                    height: 6,
                    backgroundColor: 'rgba(255,255,255,0.06)',
                    borderRadius: 4,
                    width: '100%',
                  }}
                />
              ) : null}
            </View>
            <Text style={styles.chartLabel}>{d.label}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

function ChartXp({
  serie,
  maxY,
  pad,
  gap,
}: {
  serie: PerfilSerieDia[];
  maxY: number;
  pad: number;
  gap: number;
}) {
  return (
    <View style={[styles.card, { marginHorizontal: pad, marginTop: gap }]}>
      <Text style={styles.secao}>XP GANHO</Text>
      <View style={styles.chartRow}>
        {serie.map((d) => (
          <View key={d.data} style={styles.chartCol}>
            <View style={styles.bars}>
              <View
                style={{
                  height: d.xp > 0 ? Math.max(6, (d.xp / maxY) * 88) : 6,
                  backgroundColor: d.xp > 0 ? C.primario : 'rgba(255,255,255,0.06)',
                  borderRadius: 4,
                  width: '100%',
                }}
              />
            </View>
            <Text style={styles.chartLabel}>{d.label}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

function AreaRow({
  titulo,
  a,
  f,
  t,
}: {
  titulo: string;
  a: number;
  f: number;
  t: number;
}) {
  return (
    <View style={styles.rowBetween}>
      <Text style={{ color: '#FFF', fontWeight: '600' }}>{titulo}</Text>
      <Text style={{ color: 'rgba(255,255,255,0.55)', fontWeight: '700', fontSize: 12 }}>
        {a}✓  {f}✗  {t}%
      </Text>
    </View>
  );
}

function EditBtn({
  titulo,
  valor,
  onPress,
}: {
  titulo: string;
  valor: string;
  onPress: () => void;
}) {
  return (
    <TouchableOpacity style={styles.editBtn} onPress={onPress}>
      <View>
        <Text style={styles.sub}>{titulo}</Text>
        <Text style={{ color: '#FFF', fontWeight: '600', fontSize: 15 }}>{valor}</Text>
      </View>
      <Text style={{ color: 'rgba(255,255,255,0.3)' }}>›</Text>
    </TouchableOpacity>
  );
}

function ClassePicker({
  atual,
  onClose,
  onPick,
}: {
  atual: string;
  onClose: () => void;
  onPick: (c: ClasseCatalogItem) => void;
}) {
  const [classes, setClasses] = useState<ClasseCatalogItem[]>([]);
  useEffect(() => {
    void fetchClasses().then(setClasses);
  }, []);

  return (
    <View style={styles.screenModal}>
      <View style={styles.headerModal}>
        <TouchableOpacity onPress={onClose}>
          <Text style={styles.link}>Fechar</Text>
        </TouchableOpacity>
        <Text style={styles.modalTitulo}>Trocar classe</Text>
        <View style={{ width: 50 }} />
      </View>
      <ScrollView contentContainerStyle={{ padding: 16, gap: 10 }}>
        {classes.map((c) => (
          <TouchableOpacity
            key={c.key}
            style={[
              styles.classeCard,
              atual === c.nome && { borderColor: C.primario },
            ]}
            onPress={() => onPick(c)}
          >
            <Text style={{ fontSize: 28 }}>{c.emoji}</Text>
            <View style={{ flex: 1 }}>
              <Text style={{ color: '#FFF', fontWeight: '700', fontSize: 16 }}>
                {c.nome}
              </Text>
              <Text style={styles.sub}>{c.descricao}</Text>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', gap: 12 },
  titulo: { color: '#FFF', fontSize: 30, fontWeight: '700' },
  card: {
    backgroundColor: C.card,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 16,
    gap: 12,
  },
  heroRow: { flexDirection: 'row', gap: 14, alignItems: 'center' },
  avatar: { width: 78, height: 78, borderRadius: 18 },
  nome: { color: '#FFF', fontSize: 24, fontWeight: '700' },
  nick: {
    color: C.laranja,
    fontWeight: '600',
    fontSize: 13,
    fontVariant: ['tabular-nums'],
  },
  classe: { color: C.laranja, fontWeight: '600', fontSize: 13 },
  sub: { color: C.label, fontSize: 12 },
  amigoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingVertical: 6,
    paddingHorizontal: 4,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderRadius: 12,
  },
  amigoAvatar: { width: 44, height: 44, borderRadius: 12 },
  amigoAvatarGrande: { width: 64, height: 64, borderRadius: 16 },
  amigoNome: { color: '#FFF', fontWeight: '600', fontSize: 15 },
  botaoAmigo: {
    backgroundColor: C.primario,
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 4,
  },
  botaoAmigoTexto: { color: '#FFF', fontWeight: '700', fontSize: 15 },
  secao: {
    color: C.label,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1,
  },
  rowBetween: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  xpTrack: {
    height: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.08)',
    overflow: 'hidden',
  },
  xpFill: {
    height: '100%',
    backgroundColor: C.primario,
    borderRadius: 999,
  },
  chip: {
    borderWidth: 1,
    borderColor: C.borda,
    borderRadius: 999,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  chipTexto: { color: '#FFF', fontWeight: '600', fontSize: 13 },
  statsRow: { flexDirection: 'row', gap: 8 },
  mini: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 12,
    borderRadius: 14,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    gap: 4,
  },
  miniValor: { color: '#FFF', fontWeight: '700', fontSize: 15 },
  miniLabel: { color: C.label, fontSize: 9, fontWeight: '700' },
  chartRow: { flexDirection: 'row', alignItems: 'flex-end', height: 120, gap: 4 },
  chartCol: { flex: 1, alignItems: 'center', height: '100%', justifyContent: 'flex-end', gap: 4 },
  bars: { width: '100%', justifyContent: 'flex-end', alignItems: 'stretch' },
  chartLabel: { color: 'rgba(255,255,255,0.4)', fontSize: 9 },
  editBtn: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.04)',
  },
  sair: {
    paddingVertical: 16,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.06)',
    alignItems: 'center',
  },
  sairTexto: { color: 'rgba(255,255,255,0.75)', fontWeight: '600' },
  erro: { color: 'rgba(255,255,255,0.55)', textAlign: 'center', paddingHorizontal: 8 },
  authTitulo: {
    color: '#FFF',
    fontSize: 20,
    fontWeight: '700',
    textAlign: 'center',
  },
  botaoLogin: {
    marginTop: 12,
    backgroundColor: C.primario,
    paddingHorizontal: 28,
    paddingVertical: 14,
    borderRadius: 16,
    width: '100%',
    maxWidth: 280,
    alignItems: 'center',
  },
  botaoLoginTexto: { color: '#FFF', fontWeight: '700', fontSize: 16 },
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
  },
  modalTitulo: { color: '#FFF', fontSize: 17, fontWeight: '700' },
  input: {
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: C.borda,
    padding: 14,
    color: '#FFF',
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  link: { color: 'rgba(255,255,255,0.65)', fontWeight: '600' },
  botaoSalvar: {
    backgroundColor: C.primario,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 12,
  },
  botaoSalvarTexto: { color: '#FFF', fontWeight: '700' },
  screenModal: { flex: 1, backgroundColor: '#1A1410' },
  headerModal: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 56,
    paddingBottom: 12,
  },
  avatarTile: {
    width: '22%',
    aspectRatio: 1,
    borderRadius: 14,
    borderWidth: 2,
    borderColor: C.borda,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.05)',
  },
  classeCard: {
    flexDirection: 'row',
    gap: 12,
    alignItems: 'center',
    padding: 14,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: C.borda,
    backgroundColor: C.card,
  },
});
