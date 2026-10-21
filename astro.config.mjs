// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://jaeyk.github.io',
  integrations: [react(), sitemap()],
  // Tailwind runs alongside global.scss; see src/styles/tailwind.css.
  vite: { plugins: [tailwindcss()] },
  // Emit talks/talks.html (not talks/talks/index.html) so every URL from the
  // Quarto site keeps working.
  build: { format: 'file' },
  // Keep source whitespace; compression drops the spaces around inline links.
  compressHTML: false,
});
