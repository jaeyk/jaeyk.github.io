import { CircleMarker, MapContainer, Popup, TileLayer } from 'react-leaflet';
import type { LatLngBoundsExpression } from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { MapPlace } from '../lib/talks';

interface Props {
  places: MapPlace[];
}

// Draw East Asia to the west of the Americas (longitude - 360) so the map is
// centered on the Pacific instead of spanning an empty Europe and Africa.
const shiftLng = (lng: number) => (lng > 60 ? lng - 360 : lng);

/**
 * Map of in-person talks and events, one pin per city sized by how many
 * events were held there. Rendered client-only (Leaflet needs `window`).
 */
export default function TalksMap({ places }: Props) {
  if (places.length === 0) return null;
  const points = places.map((p) => [p.lat, shiftLng(p.lng)] as [number, number]);
  const bounds: LatLngBoundsExpression = points;

  return (
    <MapContainer
      bounds={bounds}
      boundsOptions={{ padding: [30, 30] }}
      scrollWheelZoom={false}
      worldCopyJump={false}
      className="talks-map"
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {places.map((p, i) => (
        <CircleMarker
          key={p.label}
          center={points[i]}
          radius={5 + 3 * Math.sqrt(p.events.length)}
          className="talks-map-marker"
        >
          <Popup>
            <strong>{p.label}</strong>
            <ul className="talks-map-list">
              {p.events.map((e) => (
                <li key={`${e.sort}-${e.title}`}>
                  <time dateTime={e.sort}>{e.when}</time>: {e.url ? <a href={e.url}>{e.title}</a> : e.title}
                </li>
              ))}
            </ul>
          </Popup>
        </CircleMarker>
      ))}
    </MapContainer>
  );
}
