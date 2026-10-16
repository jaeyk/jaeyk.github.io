// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://jaeyk.github.io',
  integrations: [react(), sitemap()],
  // Emit talks/talks.html (not talks/talks/index.html) so every URL from the
  // Quarto site keeps working.
  build: { format: 'file' },
  // Keep source whitespace; compression drops the spaces around inline links.
  compressHTML: false,
});
