import { useEffect, useState } from 'react';

type Theme = 'dark' | 'light';

/** Light/dark switch. The initial theme is set by an inline script in Base.astro. */
export default function ThemeToggle() {
  const [theme, setTheme] = useState<Theme | null>(null);

  useEffect(() => {
    setTheme(document.documentElement.dataset.theme === 'light' ? 'light' : 'dark');
  }, []);

  function toggle() {
    const next: Theme = theme === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = next;
    try {
      localStorage.setItem('theme', next);
    } catch {
      // Storage can be unavailable (private mode); the switch still works for this page.
    }
    setTheme(next);
  }

  const label = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
  return (
    <button type="button" className="icon-button" onClick={toggle} aria-label={label} title={label}>
      <i className={`bi ${theme === 'light' ? 'bi-moon' : 'bi-sun'}`} aria-hidden="true" />
    </button>
  );
}
