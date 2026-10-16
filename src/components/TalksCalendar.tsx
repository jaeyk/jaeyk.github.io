import { useEffect, useMemo, useRef, useState } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import listPlugin from '@fullcalendar/list';
import type { EventContentArg, EventInput } from '@fullcalendar/core';
import { PAST_COLOR, TALK_COLORS, isPast, nextDay, todayKey, type Talk } from '../lib/talks';

const MOBILE = '(max-width: 768px)';
const viewFor = (mobile: boolean) => (mobile ? 'listMonth' : 'dayGridMonth');

/** Month grid on desktop, month list on phones. Past events are greyed out. */
export default function TalksCalendar({ talks }: { talks: Talk[] }) {
  const calendarRef = useRef<FullCalendar>(null);
  const [mobile] = useState(() => window.matchMedia(MOBILE).matches);

  const events = useMemo<EventInput[]>(() => {
    const today = todayKey();
    return talks.map((t) => {
      const past = isPast(t, today);
      return {
        title: t.title,
        start: t.start,
        ...(t.end && { end: nextDay(t.end) }),
        ...(t.url && { url: t.url }),
        color: past ? PAST_COLOR : TALK_COLORS[t.type],
        classNames: past ? ['is-past'] : [],
        extendedProps: { org: t.org, host: t.host, place: t.place },
      };
    });
  }, [talks]);

  useEffect(() => {
    const mq = window.matchMedia(MOBILE);
    const onChange = () => calendarRef.current?.getApi().changeView(viewFor(mq.matches));
    mq.addEventListener('change', onChange);
    return () => mq.removeEventListener('change', onChange);
  }, []);

  return (
    <FullCalendar
      ref={calendarRef}
      plugins={[dayGridPlugin, listPlugin]}
      initialView={viewFor(mobile)}
      height="auto"
      headerToolbar={{ left: 'prev,next', center: 'title', right: '' }}
      events={events}
      displayEventTime={false}
      eventContent={EventContent}
      eventClick={(info) => {
        info.jsEvent.preventDefault();
        if (info.event.url) window.open(info.event.url, '_blank', 'noopener');
      }}
    />
  );
}

function EventContent(arg: EventContentArg) {
  const { org, host, place } = arg.event.extendedProps as { org?: string; host?: string; place?: string };
  const list = arg.view.type.startsWith('list');
  return (
    <div className={`talk-event ${list ? 'talk-event-list' : 'talk-event-grid'}`}>
      <div className="talk-event-title">{arg.event.title}</div>
      {org && <div className="talk-event-org">{org}</div>}
      {host && <div className="talk-event-host">by {host}</div>}
      {place && <div className="talk-event-place">{place}</div>}
    </div>
  );
}
