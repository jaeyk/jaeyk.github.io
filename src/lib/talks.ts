import { load as loadYaml } from 'js-yaml';
import raw from '../data/talks.yaml?raw';
import placesRaw from '../data/talk-places.yaml?raw';
import historyRaw from '../data/talk-history.yaml?raw';

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

/** A past event from talk-history.yaml (CV entries before talks.yaml begins). */
interface HistoryEntry {
  year: number;
  title: string;
  kind: 'talk' | 'conference' | 'summer';
  place?: string;
  in_person?: boolean | null;
}

/** One event listed in a map pin's popup. */
export interface MapEvent {
  when: string; // "Oct. 28, 2026" or just "2019"
  sort: string; // YYYY or YYYY-MM-DD, for newest-first ordering
  title: string;
  url?: string;
}

/** One pin on the talks map: every in-person event held at the same spot. */
export interface MapPlace {
  label: string;
  lat: number;
  lng: number;
  events: MapEvent[]; // newest first
}

export interface TalkMapData {
  places: MapPlace[];
  eventCount: number; // in-person events on the map
  virtualCount: number;
  sinceYear?: number; // earliest year counted
}

/**
 * Group in-person events by location for the talks map: dated events from
 * talks.yaml plus past ones from talk-history.yaml not marked `in_person: false`.
 * Coordinates come from talk-places.yaml (`npm run places`); a place without
 * coordinates is skipped with a build warning rather than failing the build.
 */
export function loadTalkPlaces(talks: Talk[]): TalkMapData {
  const coords = (loadYaml(placesRaw) ?? {}) as Record<string, [number, number]>;
  const history = (loadYaml(historyRaw) ?? []) as HistoryEntry[];
  const byKey = new Map<string, MapPlace>();
  let eventCount = 0;
  let virtualCount = 0;
  let sinceYear: number | undefined;
  const counted = (year: number) => (sinceYear = Math.min(sinceYear ?? year, year));

  const pin = (place: string, event: MapEvent) => {
    const c = coords[place];
    if (!c) {
      console.warn(`talk-places.yaml has no coordinates for "${place}"; run \`npm run places\`.`);
      return;
    }
    // "Chapel Hill, NC" and "Chapel Hill, NC, USA" share coordinates, so they share a pin.
    const key = c.join(',');
    const p = byKey.get(key) ?? { label: place, lat: c[0], lng: c[1], events: [] };
    if (place.length > p.label.length) p.label = place;
    p.events.push(event);
    byKey.set(key, p);
    eventCount++;
    counted(Number(event.sort.slice(0, 4)));
  };

  for (const t of talks) {
    if (t.place === 'Virtual') {
      virtualCount++;
      counted(Number(t.start.slice(0, 4)));
      continue;
    }
    pin(t.place, { when: `${formatTalkDate(t)}, ${t.start.slice(0, 4)}`, sort: t.start, title: t.title, url: t.url });
  }

  for (const h of history) {
    if (h.in_person === false) {
      virtualCount++;
      counted(h.year);
    } else if (h.place) {
      pin(h.place, { when: String(h.year), sort: String(h.year), title: h.title });
    }
  }

  const places = [...byKey.values()];
  for (const p of places) p.events.sort((a, b) => b.sort.localeCompare(a.sort));
  return { places, eventCount, virtualCount, sinceYear };
}
