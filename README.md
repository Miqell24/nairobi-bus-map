# Nairobi Matatu Routes — interactive map

Interactive, poster-grade map of the **matatu network of Nairobi** — the
136 route entries Digital Matatus mapped by riding every route with a phone,
drawn along the real street geometry from Limuru and Kiambu to Kitengela and
Ngong.

## Live

**https://miqell24.github.io/nairobi-bus-map/** — GitHub Pages serves
`main:/docs`; local build on port 8185 (`npm run serve`).

Everything comes from ONE feed — the **Digital Matatus GTFS**
(<http://www.digitalmatatus.com/>; University of Nairobi C4D Lab, Columbia
CSUD, MIT Civic Data Design Lab; the 2019 survey), read from the DT4A GitLab
repository. The ArcGIS item "Nairobi Bus Routes (GTFS)" is a feature service
built from the same feed, not a download. One agency ("Approved SACCOs"),
shapes for every route, a frequencies table instead of a timetable — which
the drawn network does not need.

| mode | route_type | scope | graph |
|---|---|---|---|
| matatus | 3 | all 136 route entries, 134 lines | OSM roadways |

Line keys are the numbers painted on the vehicles — 4, 17B, 46, 105, 111,
1961K, "16/62" — and a `_2` suffix marks a second variant of the same number
(11_2, 17B_2, 3560_2), which merges into its line by the key. Every matatu is
a bus here: the family's navy. No rail, no night network.

## Pipeline

`npm run download` fetches the feed and cuts the OSM extract. **The OSM data
comes from Geofabrik, not Overpass**: `kenya-latest.osm.pbf` comes down once
and `pipeline/pbf-tiles.py` (needs `pip3 install --user osmium`) cuts a 5 × 5
road grid over the city and its satellite towns (52 × 55 km), writing exactly
the JSON shape Overpass would have returned, node ids included.

`npm run build` map-matches every line (HMM/Viterbi on the OSM graph) and
writes GeoJSON to `data/out/`; `npm run lines` adds the line-by-line view;
`npm run audit` checks the drawn result. `npm run serve` hosts the map at
<http://localhost:8185>.

Data: Digital Matatus (GTFS, 2019) · base map © OpenFreeMap / OpenMapTiles /
OpenStreetMap contributors.
