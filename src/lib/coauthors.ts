import csv from '../data/coauthors.csv?raw';

export interface Coauthor {
  name: string;
  affiliation: string;
  note: string;
  lat?: number;
  lng?: number;
}

function parseCsv(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = '';
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (c === '"') quoted = false;
      else field += c;
    } else if (c === '"') quoted = true;
    else if (c === ',') { row.push(field); field = ''; }
    else if (c === '\n' || c === '\r') {
      if (c === '\r' && text[i + 1] === '\n') i++;
      row.push(field); field = '';
      if (row.some((f) => f !== '')) rows.push(row);
      row = [];
    } else field += c;
  }
  row.push(field);
  if (row.some((f) => f !== '')) rows.push(row);
  return rows;
}

/** Coauthors from src/data/coauthors.csv (used by the coauthors page and the collaborator map). */
export function loadCoauthors(): Coauthor[] {
  const [header, ...rows] = parseCsv(csv);
  const col = (name: string) => header.indexOf(name);
  const num = (v: string | undefined) => (v && v.trim() !== '' && !Number.isNaN(Number(v)) ? Number(v) : undefined);
  return rows.map((r) => ({
    name: r[col('Name')],
    affiliation: r[col('Affiliation')],
    note: r[col('Note')] ?? '',
    lat: num(r[col('Latitude')]),
    lng: num(r[col('Longitude')]),
  }));
}
