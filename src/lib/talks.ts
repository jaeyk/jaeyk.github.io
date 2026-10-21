import { load as loadYaml } from 'js-yaml';
import raw from '../data/talks.yaml?raw';

export type TalkType = 'talk' | 'panel' | 'discussant' | 'participant' | 'visiting';

export interface Talk {
  start: string; // YYYY-MM-DD
  end?: string; // last day (inclusive), YYYY-MM-DD
  type: TalkType;
  title: string;
  org?: string;
  host?: string;
  url?: string;
  place: string;
}

export const TALK_COLORS: Record<TalkType, string> = {
  talk: '#388e3c',
  panel: '#1976d2',
  discussant: '#00796b',
  participant: '#6d4c41',
  visiting: '#455a64',
};

export const PAST_COLOR = '#aaaaaa';

const DATE = /^\d{4}-\d{2}-\d{2}$/;

export function loadTalks(): Talk[] {
  const data = (loadYaml(raw) ?? []) as Talk[];
  for (const t of data) {
    const where = `talks.yaml: "${t.title}"`;
    if (!DATE.test(String(t.start))) throw new Error(`${where} has an invalid start date "${t.start}" (use YYYY-MM-DD)`);
    if (t.end && !DATE.test(String(t.end))) throw new Error(`${where} has an invalid end date "${t.end}" (use YYYY-MM-DD)`);
    if (!(t.type in TALK_COLORS)) throw new Error(`${where} has unknown type "${t.type}"`);
  }
  return data.sort((a, b) => a.start.localeCompare(b.start));
}

/** Today's date as YYYY-MM-DD in the viewer's local time zone. */
export function todayKey(now = new Date()): string {
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${now.getFullYear()}-${m}-${d}`;
}

export const isPast = (t: Talk, today: string) => (t.end ?? t.start) < today;

export function upcomingTalks(talks: Talk[], today: string, limit = 5): Talk[] {
  return talks.filter((t) => !isPast(t, today)).slice(0, limit);
}

const MONTH_LABELS = ['Jan.', 'Feb.', 'March', 'April', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'];

/** "Nov. 4-6", "Oct. 28", or "Jan. 30-Feb. 2". */
export function formatTalkDate(t: Talk): string {
  const [, sm, sd] = t.start.split('-').map(Number);
  const startLabel = `${MONTH_LABELS[sm - 1]} ${sd}`;
  if (!t.end || t.end <= t.start) return startLabel;
  const [, em, ed] = t.end.split('-').map(Number);
  return em === sm ? `${startLabel}-${ed}` : `${startLabel}-${MONTH_LABELS[em - 1]} ${ed}`;
}

/** The day after a YYYY-MM-DD date (FullCalendar treats `end` as exclusive). */
export function nextDay(date: string): string {
  const d = new Date(`${date}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + 1);
  return d.toISOString().slice(0, 10);
}
