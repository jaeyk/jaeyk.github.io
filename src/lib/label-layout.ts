// Build-time label placement for the SVG maps (a small stand-in for ggrepel):
// each label tries spots around its point, nearest first, and takes the first
// one that overlaps no other label, point, or leader line and stays inside the map.

export interface LabelRequest {
  x: number; // the point being labeled
  y: number;
  lines: string[];
  dx?: number; // manual nudge (pixels), applied after placement
  dy?: number;
  extraHeight?: number; // added to the box, e.g. gaps between stacked rows
}

export interface PlacedLabel {
  x: number; // top-left of the label box
  y: number;
  w: number;
  h: number;
  /** Where the leader line meets the box, or undefined when the box touches the point. */
  leader?: { x: number; y: number };
}

interface Box { x: number; y: number; w: number; h: number }

export const LABEL_FONT_SIZE = 10.5;
export const LABEL_LINE_HEIGHT = 12.5;
const LABEL_PAD_X = 4;
const LABEL_PAD_Y = 2.5;
// Average glyph width for Inter at LABEL_FONT_SIZE; generous so boxes don't clip.
const CHAR_WIDTH = LABEL_FONT_SIZE * 0.56;

/** Wrap text at about `width` characters on word boundaries (like R's str_wrap). */
export function wrapText(text: string, width = 25): string[] {
  const lines: string[] = [];
  let line = '';
  for (const word of text.split(/\s+/)) {
    if (line && line.length + 1 + word.length > width) {
      lines.push(line);
      line = word;
    } else line = line ? `${line} ${word}` : word;
  }
  if (line) lines.push(line);
  return lines;
}

const overlaps = (a: Box, b: Box, gap = 2) =>
  a.x < b.x + b.w + gap && b.x < a.x + a.w + gap && a.y < b.y + b.h + gap && b.y < a.y + a.h + gap;

const hitsPoint = (b: Box, p: { x: number; y: number }, r: number) =>
  p.x > b.x - r && p.x < b.x + b.w + r && p.y > b.y - r && p.y < b.y + b.h + r;

type Segment = { x1: number; y1: number; x2: number; y2: number };

// Does a leader line pass through a box? Checked by sampling along the line.
const crosses = (s: Segment, b: Box) => {
  for (let t = 0.1; t < 1; t += 0.1) {
    const x = s.x1 + (s.x2 - s.x1) * t;
    const y = s.y1 + (s.y2 - s.y1) * t;
    if (x > b.x && x < b.x + b.w && y > b.y && y < b.y + b.h) return true;
  }
  return false;
};

/** The leader from a point to the nearest spot on its label box. */
const leaderTo = (x: number, y: number, b: Box): Segment => ({
  x1: x,
  y1: y,
  x2: Math.min(Math.max(x, b.x), b.x + b.w),
  y2: Math.min(Math.max(y, b.y), b.y + b.h),
});

// Prefer right, left, then above/below, then diagonals.
const ANGLES = [0, 180, -90, 90, -30, 30, -150, 150, -60, 60, -120, 120, -15, 15, -165, 165];
const RADII = [6, 16, 30, 48, 70, 95, 125, 160, 200, 250];

export function placeLabels(
  requests: LabelRequest[],
  points: { x: number; y: number }[],
  bounds: { w: number; h: number },
  pointRadius = 5,
): PlacedLabel[] {
  const sizes = requests.map((r) => ({
    w: Math.max(...r.lines.map((l) => l.length)) * CHAR_WIDTH + 2 * LABEL_PAD_X,
    h: r.lines.length * LABEL_LINE_HEIGHT + 2 * LABEL_PAD_Y + (r.extraHeight ?? 0),
  }));

  // Place labels in crowded areas first, while there is still room near them.
  const crowding = requests.map((r) => points.filter((p) => Math.hypot(p.x - r.x, p.y - r.y) < 120).length);
  const order = requests.map((_, i) => i).sort((a, b) => crowding[b] - crowding[a]);

  const placed: (PlacedLabel | undefined)[] = [];
  const boxes: Box[] = [];
  const leaders: Segment[] = [];
  for (const i of order) {
    const { x, y } = requests[i];
    const { w, h } = sizes[i];
    let best: Box | undefined;
    let bestCost = Infinity;
    search: for (const r of RADII) {
      for (const deg of ANGLES) {
        const a = (deg * Math.PI) / 180;
        const cx = x + Math.cos(a) * (r + w / 2);
        const cy = y + Math.sin(a) * (r + h / 2);
        const box = { x: cx - w / 2, y: cy - h / 2, w, h };
        const outside = box.x < 0 || box.y < 0 || box.x + w > bounds.w || box.y + h > bounds.h;
        const leader = leaderTo(x, y, box);
        const cost =
          (outside ? 100 : 0) +
          boxes.filter((b) => overlaps(box, b)).length * 10 +
          boxes.filter((b) => crosses(leader, b)).length * 8 +
          leaders.filter((l) => crosses(l, box)).length * 8 +
          points.filter((p) => hitsPoint(box, p, pointRadius)).length +
          r / 100; // among equal options, stay close to the point
        if (cost < bestCost) {
          best = box;
          bestCost = cost;
        }
        if (cost < 1) break search;
      }
    }
    const box = { ...best!, x: best!.x + (requests[i].dx ?? 0), y: best!.y + (requests[i].dy ?? 0) };
    boxes.push(box);
    // Draw a leader line only if the box sits away from its point.
    const leader = leaderTo(x, y, box);
    const far = Math.hypot(leader.x2 - x, leader.y2 - y) > pointRadius + 4;
    if (far) leaders.push(leader);
    placed[i] = { ...box, leader: far ? { x: leader.x2, y: leader.y2 } : undefined };
  }
  return placed as PlacedLabel[];
}
