import { useEffect, useRef, useState } from 'react';

declare global {
  interface Window {
    PagefindUI?: new (options: Record<string, unknown>) => unknown;
  }
}

/**
 * Site search powered by Pagefind. The index is generated after `astro build`
 * (see the "build" script), so search only works on a built site, not in `astro dev`.
 */
export default function SiteSearch() {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [status, setStatus] = useState<'idle' | 'loading' | 'ready' | 'unavailable'>('idle');

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        open();
      }
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  });

  function loadPagefind() {
    if (status !== 'idle') return;
    setStatus('loading');
    const css = document.createElement('link');
    css.rel = 'stylesheet';
    css.href = '/pagefind/pagefind-ui.css';
    document.head.appendChild(css);
    const script = document.createElement('script');
    script.src = '/pagefind/pagefind-ui.js';
    script.onload = () => {
      if (!window.PagefindUI) return setStatus('unavailable');
      new window.PagefindUI({ element: '#site-search', showSubResults: true, autofocus: true, translations: { placeholder: 'Search this site...' } });
      setStatus('ready');
    };
    script.onerror = () => setStatus('unavailable');
    document.head.appendChild(script);
  }

  function open() {
    dialogRef.current?.showModal();
    loadPagefind();
  }

  return (
    <>
      <button type="button" className="icon-button" onClick={open} aria-label="Search this site" title="Search (⌘K)">
        <i className="bi bi-search" aria-hidden="true" />
      </button>
      <dialog
        ref={dialogRef}
        className="search-dialog"
        aria-label="Search this site"
        onClick={(e) => e.target === dialogRef.current && dialogRef.current?.close()}
      >
        <div className="search-dialog-body">
          <button type="button" className="dialog-close" aria-label="Close" onClick={() => dialogRef.current?.close()}>
            &times;
          </button>
          <div id="site-search" />
          {status === 'loading' && <p className="muted">Loading search…</p>}
          {status === 'unavailable' && (
            <p className="muted">Search is available on the built site (run <code>npm run build</code> then <code>npm run preview</code>).</p>
          )}
        </div>
      </dialog>
    </>
  );
}
