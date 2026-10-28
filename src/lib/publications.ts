import { load as loadYaml } from 'js-yaml';
import { marked } from 'marked';
import journalRaw from '../data/journal-articles.yaml?raw';
import otherRaw from '../data/other-publications.yaml?raw';

export interface JournalArticle {
  order: number;
  year: number | string;
  title: string;
  url?: string | null;
  authors: string[];
  equal_coauthors?: string[];
  venue?: string;
  citation?: string;
  links?: { label: string; url: string }[];
  note?: string;
  date?: string; // YYYY-MM-DD; overrides the date parsed from citation for the homepage list
}

/** A non-journal entry, pre-rendered for the publications page. */
export interface OtherItem {
  html: string;
  notesHtml: string[];
  search: string; // lowercase plain text + link URLs
}

export interface OtherSection {
  key: string;
  title: string;
  items: OtherItem[];
}

interface RawSection {
  key: string;
  title: string;
  items: { text: string; notes?: string[] }[];
}

export function loadJournalArticles(): JournalArticle[] {
  const papers = (loadYaml(journalRaw) ?? []) as JournalArticle[];
  return papers.sort((a, b) => Number(b.order) - Number(a.order));
}

function loadRawSections(): RawSection[] {
  return ((loadYaml(otherRaw) ?? []) as RawSection[]).map((s) => ({ ...s, items: s.items ?? [] }));
}

const inline = (md: string) => marked.parseInline(md, { async: false }) as string;
const urlsIn = (md: string) => [...md.matchAll(/\]\(([^)\s]+)\)/g)].map((m) => m[1]);
export const stripMarkdown = (md: string) =>
  md
    .replace(/\\([[\]])/g, '$1')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/\*\*?([^*]+)\*\*?/g, '$1');

export function loadOtherSections(): OtherSection[] {
  return loadRawSections().map((s) => ({
    key: s.key,
    title: s.title,
    items: s.items.map((item) => {
      const notes = item.notes ?? [];
      const all = [item.text, ...notes].join(' ');
      return {
        html: inline(item.text),
        notesHtml: notes.map(inline),
        search: `${stripMarkdown(all)} ${urlsIn(all).join(' ')}`.toLowerCase(),
      };
    }),
  }));
}

// ------------------------------------------------------------ homepage list

export interface RecentItem {
  title: string;
  url?: string;
  meta: string;
}

const MONTHS: Record<string, number> = {
  January: 1, February: 2, March: 3, April: 4, May: 5, June: 6, July: 7, August: 8,
  September: 9, October: 10, November: 11, December: 12, Jan: 1, Feb: 2, Mar: 3, Apr: 4,
  Jun: 6, Jul: 7, Aug: 8, Sep: 9, Sept: 9, Oct: 10, Nov: 11, Dec: 12,
};
const MONTH_RE = Object.keys(MONTHS).join('|');

/** Best-effort date from free text ("June 8, 2026", "April 2025", "2023"). */
function dateFromText(text: string, fallbackYear?: number | string): string {
  if (/forthcoming/i.test(text)) return '9999-12-31';
  const t = text.replace(/\./g, '');
  let m = t.match(new RegExp(`\\b(${MONTH_RE})\\s+(\\d{1,2}),?\\s+(20\\d{2})\\b`));
  if (m) return `${m[3]}-${String(MONTHS[m[1]]).padStart(2, '0')}-${m[2].padStart(2, '0')}`;
  m = t.match(new RegExp(`\\b(${MONTH_RE})\\s+(20\\d{2})\\b`));
  if (m) return `${m[2]}-${String(MONTHS[m[1]]).padStart(2, '0')}-01`;
  m = t.match(/20\d{2}/);
  if (m) return `${m[0]}-01-01`;
  return fallbackYear ? `${fallbackYear}-01-01` : '1900-01-01';
}

const RECENT_SECTIONS = ['book_chapters', 'proceedings', 'policy_memos', 'media_interviews', 'public_writing'];

/** Newest publications and media for the homepage (forthcoming work first). */
export function recentPublications(limit = 5): RecentItem[] {
  const pool: (RecentItem & { date: string; order: number })[] = [];

  for (const p of loadJournalArticles()) {
    const venue = p.venue ?? '';
    const citation = p.citation ?? '';
    const meta = citation.includes('{venue}')
      ? citation.replace('{venue}', venue)
      : [venue, citation].filter(Boolean).join(', ');
    pool.push({ title: p.title, url: p.url ?? undefined, meta, date: p.date ? String(p.date) : dateFromText(citation, p.year), order: Number(p.order) });
  }

  for (const section of loadRawSections().filter((s) => RECENT_SECTIONS.includes(s.key))) {
    for (const { text } of section.items) {
      const link = text.match(/^\["?(.+?)"?\]\(([^)]+)\)/);
      const plain = text.match(/^"(.+?)"/);
      const title = link ? link[1] : plain ? plain[1] : text.replace(/\s*\(.*$/, '');
      const rest = text.slice((link ?? plain)?.[0].length ?? 0);
      const meta = stripMarkdown(rest).replace(/^\s*\([^)]*\),?\s*/, '').trim();
      pool.push({ title, url: link?.[2], meta, date: dateFromText(text), order: 0 });
    }
  }

  return pool
    .sort((a, b) => b.date.localeCompare(a.date) || b.order - a.order)
    .slice(0, limit)
    .map(({ title, url, meta }) => ({ title, url, meta }));
}
