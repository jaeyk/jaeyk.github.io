import { useEffect, useState } from 'react';
import { formatTalkDate, todayKey, upcomingTalks, type Talk } from '../lib/talks';

interface Props {
  talks: Talk[];
  buildDate: string; // YYYY-MM-DD the site was built
}

/**
 * Homepage list of the next few events. Rendered at build time, then
 * recomputed in the browser so it never goes stale between deploys.
 */
export default function UpcomingTalks({ talks, buildDate }: Props) {
  const [today, setToday] = useState(buildDate);
  useEffect(() => setToday(todayKey()), []);

  const items = upcomingTalks(talks, today);
  if (items.length === 0) return <p className="muted">No upcoming events right now.</p>;

  return (
    <ol>
      {items.map((t) => {
        const detail = t.org ? `${t.title}, ${t.org}` : t.title;
        return (
          <li key={`${t.start}-${t.title}`}>
            <time dateTime={t.start}>{formatTalkDate(t)}.</time> {t.url ? <a href={t.url}>{detail}</a> : detail}
          </li>
        );
      })}
    </ol>
  );
}
