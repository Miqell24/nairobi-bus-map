#!/usr/bin/env bash
# Downloads input data: the Digital Matatus GTFS, the OSM extract (Geofabrik), MapLibre GL.
# Everything is cached — re-running only fetches what is missing.
#
# Nairobi: the matatu network as Digital Matatus mapped it (University of
# Nairobi C4D Lab, Columbia CSUD, MIT Civic Data Design Lab; the 2019
# survey). The canonical copy sits in the DT4A GitLab repository; the ArcGIS
# "Nairobi Bus Routes (GTFS)" item is a feature service built from the same
# feed, not a download. MobilityDatabase lists it as mdb-1815.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/osm/tiles web/vendor

need_osmium () {
  python3 -c "import osmium" 2>/dev/null && return 0
  echo "brak pakietu osmium — zainstaluj: pip3 install --user osmium" >&2
  return 1
}

# 1) GTFS
if [ ! -f data/gtfs/routes.txt ]; then
  echo "== Digital Matatus GTFS =="
  curl -fL --retry 3 --max-time 600 -o data/nairobi-gtfs.zip \
    "https://gitlab.com/digitaltransport/data/africa/nairobi/-/raw/master/Data/GTFS.zip?inline=false" \
    || curl -fL --retry 3 --max-time 600 -o data/nairobi-gtfs.zip "https://files.mobilitydatabase.org/mdb-1815/latest.zip"
  mkdir -p data/gtfs
  unzip -q -o data/nairobi-gtfs.zip -d data/gtfs
fi

# 2) OSM — from the Geofabrik Kenya extract; pipeline/pbf-tiles.py cuts the
#    5 × 5 road grid (the city and its satellite towns, 52 × 55 km) in the
#    JSON shape Overpass would have returned, node ids included.
if [ ! -f data/osm/tiles/t25.json ]; then
  need_osmium
  if [ ! -f data/kenya-latest.osm.pbf ]; then
    echo "== Geofabrik kenya-latest.osm.pbf =="
    curl -fL --retry 5 --retry-delay 5 -C - --max-time 3600 -o data/kenya-latest.osm.pbf \
      "https://download.geofabrik.de/africa/kenya-latest.osm.pbf"
  fi
  echo "== cutting OSM tiles out of the extract =="
  python3 pipeline/pbf-tiles.py
fi

# 3) MapLibre GL (vendored, no CDN at runtime)
if [ ! -f web/vendor/maplibre-gl.js ]; then
  echo "== MapLibre GL =="
  curl -fL --retry 3 -o web/vendor/maplibre-gl.js  https://unpkg.com/maplibre-gl@5.6.1/dist/maplibre-gl.js
  curl -fL --retry 3 -o web/vendor/maplibre-gl.css https://unpkg.com/maplibre-gl@5.6.1/dist/maplibre-gl.css
fi

echo "OK — data ready:"
du -sh data/gtfs data/osm 2>/dev/null || true
