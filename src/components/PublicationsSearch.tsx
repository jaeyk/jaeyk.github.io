import { useMemo, useState, type ReactNode, type SyntheticEvent } from 'react';
import type { JournalArticle, OtherSection } from '../lib/publications';

interface Props {
  articles: JournalArticle[];
  sections: OtherSection[];
}

const SELF = 'jae yeon kim';

function articleSearchText(p: JournalArticle) {
  return [p.title, p.authors.join(' '), p.venue, p.citation, p.year, (p.links ?? []).map((l) => `${l.label} ${l.url}`).join(' '), p.url]
    .join(' ')
    .toLowerCase();
}

function Authors({ authors, equal = [] }: { authors: string[]; equal?: string[] }) {
  const equalSet = new Set(equal.map((n) => n.toLowerCase().trim()));
  const names = authors.map((name, i) => {
    const label = name + (equalSet.has(name.toLowerCase().trim()) ? '+' : '');
    return name.toLowerCase().includes(SELF) ? <strong key={i}>{label}</strong> : <span key={i}>{label}</span>;
  });
  const out: ReactNode[] = [];
  names.forEach((n, i) => {
    if (i > 0) out.push(names.length === 2 ? ' and ' : i === names.length - 1 ? ', and ' : ', ');
    out.push(n);
  });
  return <>{out}</>;
}

function Article({ p, value }: { p: JournalArticle; value: number }) {
  const title = `"${p.title}"`;
  const venue = p.venue ? <em>{p.venue}</em> : null;
  const citation = p.citation ?? '';
  let venueAndCitation: ReactNode;
  if (citation.includes('{venue}')) {
    const [before, after] = citation.split('{venue}');
    venueAndCitation = <>{before}{venue}{after}</>;
  } else {
    venueAndCitation = <>{venue}{venue && ', '}{citation}</>;
  }
  return (
    <li value={value}>
      <p>
        {p.url ? <a href={p.url}>{title}</a> : title} (<Authors authors={p.authors} equal={p.equal_coauthors} />) {venueAndCitation}
        {(p.equal_coauthors ?? []).length > 0 && ' (+ = co-lead authors.)'}
        {(p.links ?? []).map((l) => (
          <span key={l.url}>
            {' '}[<a href={l.url}>{l.label}</a>]
          </span>
        ))}
      </p>
      {p.note && (
        <ul>
          <li>{p.note}</li>
        </ul>
      )}
    </li>
  );
}

export default function PublicationsSearch({ articles, sections }: Props) {
  const [query, setQuery] = useState('');
  // Which sections the visitor has opened; while searching, sections with matches open automatically.
  const [userOpen, setUserOpen] = useState<Record<string, boolean>>({ journal: true });
  const q = query.toLowerCase().trim();

  const searchText = useMemo(() => articles.map(articleSearchText), [articles]);
  const matchedArticles = articles.filter((_, i) => !q || searchText[i].includes(q));
  const matchedSections = sections.map((s) => ({ ...s, items: s.items.filter((it) => !q || it.search.includes(q)) }));

  const total = articles.length + sections.reduce((n, s) => n + s.items.length, 0);
  const matches = matchedArticles.length + matchedSections.reduce((n, s) => n + s.items.length, 0);
  const count = (key: string) => sections.find((s) => s.key === key)?.items.length ?? 0;
  const underReview = count('under_review');
  const preparing = count('reading_for_submission');
  const inProgress = count('work_in_progress');

  const isOpen = (key: string, matchCount: number) => (q ? matchCount > 0 : !!userOpen[key]);
  const onToggle = (key: string) => (e: SyntheticEvent<HTMLDetailsElement>) => {
    const open = e.currentTarget.open;
    if (!q && open !== !!userOpen[key]) setUserOpen((prev) => ({ ...prev, [key]: open }));
  };

  // Journal articles grouped by year (newest first), numbered down across groups.
  const byYear = new Map<string, JournalArticle[]>();
  for (const p of matchedArticles) {
    const y = String(p.year ?? 'Unknown');
    byYear.set(y, [...(byYear.get(y) ?? []), p]);
  }
  const years = [...byYear.keys()].sort((a, b) => Number(b) - Number(a));
  let running = matchedArticles.length;

  return (
    <>
      <div className="pub-search-controls">
        <label htmlFor="pub-search-input">
          <strong>Search publications</strong>
        </label>
        <input
          id="pub-search-input"
          type="search"
          placeholder="Type title, author, journal, year, or link"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <span className="pub-search-status" aria-live="polite">
          {matches} {matches === 1 ? 'match' : 'matches'} of {total} total
        </span>
        <span className="pub-search-status">
          Published papers: {articles.length} | Proceedings: {count('proceedings')} | Book chapters: {count('book_chapters')} | Policy
          memos: {count('policy_memos')} | Media: {count('media_interviews')} | Public writing: {count('public_writing')}
          <br />
          Pipeline: {underReview + preparing + inProgress} (Under review: {underReview}, Preparing for submission: {preparing}, Work in
          progress: {inProgress})
        </span>
      </div>

      <details open={isOpen('journal', matchedArticles.length)} onToggle={onToggle('journal')}>
        <summary>
          <strong>Peer-reviewed journal articles</strong>
        </summary>
        {matchedArticles.length === 0 && <p>No matching papers found.</p>}
        {years.map((year) => (
          <div key={year}>
            <h4 className="pub-year-heading">{year}</h4>
            <ol>
              {byYear.get(year)!.map((p) => (
                <Article key={p.order} p={p} value={running--} />
              ))}
            </ol>
          </div>
        ))}
      </details>

      {matchedSections.map((s) => (
        <details key={s.key} open={isOpen(s.key, s.items.length)} onToggle={onToggle(s.key)}>
          <summary>
            <strong>{s.title}</strong>
          </summary>
          <ol reversed>
            {s.items.map((item, i) => (
              <li key={i}>
                <p dangerouslySetInnerHTML={{ __html: item.html }} />
                {item.notesHtml.length > 0 && (
                  <ul>
                    {item.notesHtml.map((n, j) => (
                      <li key={j} dangerouslySetInnerHTML={{ __html: n }} />
                    ))}
                  </ul>
                )}
              </li>
            ))}
          </ol>
        </details>
      ))}
    </>
  );
}
