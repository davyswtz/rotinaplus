import notifee, {
  AndroidImportance,
  AuthorizationStatus,
  RepeatFrequency,
  TimestampTrigger,
  TriggerType,
} from '@notifee/react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { PermissionsAndroid, Platform } from 'react-native';
import { CacheKeys, loadCache } from './store';
import type { DashboardData, HabitoJournal } from '../types';

const ATIVOS_KEY = 'lembretes_ativos';
const HORA_MANHA_KEY = 'lembretes_hora_manha';
const HORA_NOITE_KEY = 'lembretes_hora_noite';
const CHANNEL_ID = 'rotinaplus_lembretes';

async function getAtivos(): Promise<boolean> {
  const v = await AsyncStorage.getItem(ATIVOS_KEY);
  return v === null ? true : v === '1';
}

export async function setLembretesAtivos(ativos: boolean): Promise<void> {
  await AsyncStorage.setItem(ATIVOS_KEY, ativos ? '1' : '0');
  await reagendarLembretes();
}

export async function getHoraManha(): Promise<number> {
  const v = await AsyncStorage.getItem(HORA_MANHA_KEY);
  const n = v ? Number(v) : 9;
  return Number.isFinite(n) ? n : 9;
}

export async function setHoraManha(hora: number): Promise<void> {
  await AsyncStorage.setItem(HORA_MANHA_KEY, String(Math.min(23, Math.max(0, hora))));
  await reagendarLembretes();
}

export async function getHoraNoite(): Promise<number> {
  const v = await AsyncStorage.getItem(HORA_NOITE_KEY);
  const n = v ? Number(v) : 20;
  return Number.isFinite(n) ? n : 20;
}

export async function setHoraNoite(hora: number): Promise<void> {
  await AsyncStorage.setItem(HORA_NOITE_KEY, String(Math.min(23, Math.max(0, hora))));
  await reagendarLembretes();
}

async function garantirCanal(): Promise<void> {
  if (Platform.OS !== 'android') return;
  await notifee.createChannel({
    id: CHANNEL_ID,
    name: 'Lembretes Rotina Plus',
    importance: AndroidImportance.HIGH,
  });
}

export async function pedirPermissaoLembretes(): Promise<boolean> {
  if (Platform.OS === 'android' && Platform.Version >= 33) {
    const r = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS,
    );
    if (r !== PermissionsAndroid.RESULTS.GRANTED) return false;
  }
  const settings = await notifee.requestPermission();
  return (
    settings.authorizationStatus === AuthorizationStatus.AUTHORIZED ||
    settings.authorizationStatus === AuthorizationStatus.PROVISIONAL
  );
}

function proximoHorario(hora: number, minuto = 0): Date {
  const d = new Date();
  d.setSeconds(0, 0);
  d.setHours(hora, minuto, 0, 0);
  if (d.getTime() <= Date.now()) {
    d.setDate(d.getDate() + 1);
  }
  return d;
}

async function agendarDiario(
  id: string,
  hora: number,
  minuto: number,
  titulo: string,
  corpo: string,
): Promise<void> {
  const trigger: TimestampTrigger = {
    type: TriggerType.TIMESTAMP,
    timestamp: proximoHorario(hora, minuto).getTime(),
    repeatFrequency: RepeatFrequency.DAILY,
  };
  await notifee.createTriggerNotification(
    {
      id,
      title: titulo,
      body: corpo,
      android: {
        channelId: CHANNEL_ID,
        pressAction: { id: 'default' },
        smallIcon: 'ic_launcher',
      },
    },
    trigger,
  );
}

export async function cancelarLembretes(): Promise<void> {
  const ids = await notifee.getTriggerNotificationIds();
  const nossos = ids.filter((id) => id.startsWith('rp.lembrete.'));
  if (nossos.length) await notifee.cancelTriggerNotifications(nossos);
}

export async function reagendarLembretes(): Promise<void> {
  await cancelarLembretes();
  const ativos = await getAtivos();
  if (!ativos) return;

  const ok = await pedirPermissaoLembretes();
  if (!ok) return;

  await garantirCanal();

  const dash = await loadCache<DashboardData>(CacheKeys.dashboard);
  const missoesPendentes =
    dash?.missoes?.filter((m) => !m.concluida).length ?? 0;
  const habitos = await loadCache<HabitoJournal>(CacheKeys.habitos());
  const habitosPendentes =
    habitos?.itens?.filter((i) => !i.concluida).length ??
    (dash?.habitos_resumo
      ? Math.max(0, dash.habitos_resumo.total - dash.habitos_resumo.concluidos)
      : 0);
  const total = missoesPendentes + habitosPendentes;

  const horaManha = await getHoraManha();
  const horaNoite = await getHoraNoite();

  await agendarDiario(
    'rp.lembrete.manha',
    horaManha,
    0,
    '🦊 Missões do dia',
    total > 0
      ? 'Você tem desafios te esperando. Bora completar a rotina!'
      : 'Novo dia, novas missões. Abra o Rotina Plus e comece!',
  );

  await agendarDiario(
    'rp.lembrete.noite',
    horaNoite,
    0,
    '🔥 Ainda dá tempo',
    total > 0
      ? `Faltam ${total} desafio(s) hoje. Finalize antes de dormir!`
      : 'Dia limpo! Que tal revisar amanhã e manter a sequência?',
  );

  const itens = (habitos?.itens ?? []).slice(0, 8);
  for (const item of itens) {
    if (item.habito.ativo === false) continue;
    await agendarDiario(
      `rp.lembrete.habito.${item.habito.id}`,
      horaManha,
      30,
      `${item.habito.icone} ${item.habito.titulo}`,
      item.concluida
        ? 'Já feito hoje — amanhã de novo!'
        : item.habito.detalhe || 'Hora do seu hábito. Marque no diário!',
    );
  }
}

export async function iniciarLembretes(): Promise<void> {
  await garantirCanal();
  await reagendarLembretes();
}

export { getAtivos as getLembretesAtivos };
