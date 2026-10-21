// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://jaeyk.github.io',
  integrations: [react(), mdx(), sitemap()],
  // Tailwind runs alongside global.scss; see src/styles/tailwind.css.
  vite: {
    plugins: [tailwindcss()],
    // Talks page islands are client:only, so the dev server can't discover
    // their libraries at startup; pre-bundle them so the first visit doesn't
    // hit "Outdated Optimize Dep" errors.
    optimizeDeps: {
      include: ['react-leaflet', 'leaflet', '@fullcalendar/react', '@fullcalendar/core', '@fullcalendar/daygrid', '@fullcalendar/list'],
    },
  },
  // Emit talks/talks.html (not talks/talks/index.html) so every URL from the
  // Quarto site keeps working.
  build: { format: 'file' },
  // Keep source whitespace; compression drops the spaces around inline links.
  compressHTML: false,
});
