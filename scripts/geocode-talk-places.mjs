// Look up map coordinates for every `place` in talks.yaml and talk-history.yaml
// that isn't in talk-places.yaml yet, and save them there. Run after adding a talk in a new
// city: `npm run places`. Uses OpenStreetMap's Nominatim (one request per second).
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { load, dump } from 'js-yaml';

const TALKS = 'src/data/talks.yaml';
const HISTORY = 'src/data/talk-history.yaml';
const PLACES = 'src/data/talk-places.yaml';
const HEADER = `# Map coordinates [latitude, longitude] for each \`place\` in talks.yaml and
# talk-history.yaml, used by
# the map on the talks page. Filled in by \`npm run places\`; edit by hand if a
# lookup lands in the wrong spot. "Virtual" events are left off the map.\n\n`;

const talks = [...(load(readFileSync(TALKS, 'utf8')) ?? []), ...(load(readFileSync(HISTORY, 'utf8')) ?? [])];
const places = existsSync(PLACES) ? (load(readFileSync(PLACES, 'utf8')) ?? {}) : {};

const missing = [...new Set(talks.map((t) => t.place))].filter((p) => p && p !== 'Virtual' && !(p in places));
if (missing.length === 0) {
  console.log('All places already have coordinates.');
  process.exit(0);
}

for (const place of missing) {
  const url = `https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${encodeURIComponent(place)}`;
  const res = await fetch(url, { headers: { 'User-Agent': 'jaeyk.github.io talks map (https://jaeyk.github.io)' } });
  const [hit] = res.ok ? await res.json() : [];
  if (hit) {
    places[place] = [Number(Number(hit.lat).toFixed(3)), Number(Number(hit.lon).toFixed(3))];
    console.log(`${place} → ${places[place].join(', ')}  (${hit.display_name})`);
  } else {
    console.warn(`Not found: ${place} (add its coordinates to ${PLACES} by hand)`);
  }
  await new Promise((r) => setTimeout(r, 1100));
}

const sorted = Object.fromEntries(Object.entries(places).sort(([a], [b]) => a.localeCompare(b)));
writeFileSync(PLACES, HEADER + dump(sorted, { flowLevel: 1 }));
