#!/bin/bash

# Automatic generation for:
# - Mapsforge maps
# - Mapsforge pois
# - GraphHopper graphs
# with OpenStreetMap data from Geofabrik
#
# written by devemux86

# Configuration

[ $MAP_CREATION ] || MAP_CREATION="true"
[ $POI_CREATION ] || POI_CREATION="true"
[ $GRAPH_CREATION ] || GRAPH_CREATION="true"

[ $OSMOSIS_HOME ] || OSMOSIS_HOME="/usr/bin"
[ $DATA_PATH ] || DATA_PATH="$HOME/mapsforge/data"
[ $MAPS_PATH ] || MAPS_PATH="$HOME/mapsforge/maps"
[ $POIS_PATH ] || POIS_PATH="$HOME/mapsforge/pois"

[ $GRAPHHOPPER_FILE ] || GRAPHHOPPER_FILE="graphhopper-web-1.0.jar"
[ $GRAPHHOPPER_CONFIG ] || GRAPHHOPPER_CONFIG="config.yml"
[ $GRAPHS_PATH ] || GRAPHS_PATH="$HOME/mapsforge/graphs"

[ $DAYS ] || DAYS="30"

[ $MAP_TRANSFORM_FILE ] || MAP_TRANSFORM_FILE="tag-transform.xml"
[ $TAG_VALUES ] || TAG_VALUES="true"
[ $COMMENT ] || COMMENT="Map data (c) OpenStreetMap contributors"
[ $PROGRESS_LOGS ] || PROGRESS_LOGS="true"

# =========== DO NOT CHANGE AFTER THIS LINE. ===========================
# Below here is regular code, part of the file. This is not designed to
# be modified by users.
# ======================================================================

if [ $# -lt 1 ]; then
  echo "Usage: $0 continent/country[/region] [ram|hd] [lang1,...,langN] [1...N]"
  echo "Example: $0 europe/germany/berlin ram en,de,fr,es 1"
  exit
fi

cd "$(dirname "$0")"

NAME="$(basename "$1")"

WORK_PATH="$DATA_PATH/$1"

if [ "$TAG_VALUES" = "true" ]; then
  MAPS_PATH="$MAPS_PATH/v5"
else
  [ $3 ] && MAPS_PATH="$MAPS_PATH/v4" || MAPS_PATH="$MAPS_PATH/v3"
fi
MAPS_PATH="$(dirname "$MAPS_PATH/$1")"

POIS_PATH="$(dirname "$POIS_PATH/$1")"

GRAPHS_PATH="$(dirname "$GRAPHS_PATH/$1")"

# Check dates

if [ "$MAP_CREATION" = "true" ]; then
  if [ -f "$MAPS_PATH/$NAME.map" ] && [ $(find "$MAPS_PATH/$NAME.map" -mtime -$DAYS) ]; then
    echo "$MAPS_PATH/$NAME.map exists and is newer than $DAYS days."
    MAP_CREATION="false"
  fi
fi

if [ "$POI_CREATION" = "true" ]; then
  if [ -f "$POIS_PATH/$NAME.poi" ] && [ $(find "$POIS_PATH/$NAME.poi" -mtime -$DAYS) ]; then
    echo "$POIS_PATH/$NAME.poi exists and is newer than $DAYS days."
    POI_CREATION="false"
  fi
fi

if [ "$GRAPH_CREATION" = "true" ]; then
  if [ -f "$GRAPHS_PATH/$NAME.zip" ] && [ $(find "$GRAPHS_PATH/$NAME.zip" -mtime -$DAYS) ]; then
    echo "$GRAPHS_PATH/$NAME.zip exists and is newer than $DAYS days."
    GRAPH_CREATION="false"
  fi
fi

if [ "$MAP_CREATION" = "false" ] && [ "$POI_CREATION" = "false" ] && [ "$GRAPH_CREATION" = "false" ]; then
  exit
fi

# Pre-process

rm -rf "$WORK_PATH"
mkdir -p "$WORK_PATH"

if [ "$MAP_CREATION" = "true" ]; then
  mkdir -p "$MAPS_PATH"
fi

if [ "$POI_CREATION" = "true" ]; then
  mkdir -p "$POIS_PATH"
fi

if [ "$GRAPH_CREATION" = "true" ]; then
  mkdir -p "$GRAPHS_PATH"
fi

# Download data

echo "Downloading $1..."
wget -nv -N -P "$WORK_PATH" https://download.geofabrik.de/$1-latest.osm.pbf || exit 1
wget -nv -N -P "$WORK_PATH" https://download.geofabrik.de/$1-latest.osm.pbf.md5 || exit 1
(cd "$WORK_PATH" && exec md5sum -c "$NAME-latest.osm.pbf.md5") || exit 1
wget -nv -N -P "$WORK_PATH" https://download.geofabrik.de/$1.poly || exit 1

# ========== Map ==========

if [ "$MAP_CREATION" = "true" ]; then

  # Download land

  if [ -f "$DATA_PATH/land-polygons-split-4326/land_polygons.shp" ] && [ $(find "$DATA_PATH/land-polygons-split-4326/land_polygons.shp" -mtime -$DAYS) ]; then
    echo "Land polygons exist and are newer than $DAYS days."
  else
    echo "Downloading land polygons..."
    rm -rf "$DATA_PATH/land-polygons-split-4326"
    rm -f "$DATA_PATH/land-polygons-split-4326.zip"
    wget -nv -N -P "$DATA_PATH" https://osmdata.openstreetmap.de/download/land-polygons-split-4326.zip || exit 1
    unzip -oq "$DATA_PATH/land-polygons-split-4326.zip" -d "$DATA_PATH"
  fi

  # Bounds

  BBOX=$(perl poly2bb.pl "$WORK_PATH/$NAME.poly")
  BBOX=(${BBOX//,/ })
  BOTTOM=${BBOX[0]}
  LEFT=${BBOX[1]}
  TOP=${BBOX[2]}
  RIGHT=${BBOX[3]}

  # Start position

  CENTER=$(perl poly2center.pl "$WORK_PATH/$NAME.poly")
  CENTER=(${CENTER//,/ })
  LAT=${CENTER[0]}
  LON=${CENTER[1]}

  # Land

  ogr2ogr -overwrite -progress -skipfailures -clipsrc $LEFT $BOTTOM $RIGHT $TOP "$WORK_PATH/land.shp" "$DATA_PATH/land-polygons-split-4326/land_polygons.shp"
  python3 shape2osm.py -l "$WORK_PATH/land" "$WORK_PATH/land.shp"

  # Sea

  cp sea.osm "$WORK_PATH"
  sed -i "s/\$BOTTOM/$BOTTOM/g" "$WORK_PATH/sea.osm"
  sed -i "s/\$LEFT/$LEFT/g" "$WORK_PATH/sea.osm"
  sed -i "s/\$TOP/$TOP/g" "$WORK_PATH/sea.osm"
  sed -i "s/\$RIGHT/$RIGHT/g" "$WORK_PATH/sea.osm"

  # Merge

  CMD="$OSMOSIS_HOME/osmosis --rb file=$WORK_PATH/$NAME-latest.osm.pbf \
                                 --rx file=$WORK_PATH/sea.osm --s --m"
  for f in $WORK_PATH/land*.osm; do
    CMD="$CMD --rx file=$f --s --m"
  done
  CMD="$CMD --wb file=$WORK_PATH/merge.pbf omitmetadata=true"
  echo $CMD
  eval "$CMD" || exit 1

  # Map writer

  CMD="$OSMOSIS_HOME/osmosis --rb file=$WORK_PATH/merge.pbf \
                                 --tt file=$MAP_TRANSFORM_FILE \
                                 --mw file=$WORK_PATH/$NAME.map \
                                      bbox=$BOTTOM,$LEFT,$TOP,$RIGHT \
                                      map-start-position=$LAT,$LON \
                                      map-start-zoom=8 \
                                      tag-values=$TAG_VALUES \
                                      comment=\"$COMMENT\" \
                                      progress-logs=$PROGRESS_LOGS"
  [ $2 ] && CMD="$CMD type=$2"
  [ $3 ] && CMD="$CMD preferred-languages=$3"
  [ $4 ] && CMD="$CMD threads=$4"
  [ $MAP_TAG_CONF_FILE ] && CMD="$CMD tag-conf-file=$MAP_TAG_CONF_FILE"
  echo $CMD
  eval "$CMD" || exit 1

  # Check map size

  if [ -f "$MAPS_PATH/$NAME.map" ]; then
    OLD_SIZE=$(wc -c < "$MAPS_PATH/$NAME.map")
    NEW_SIZE=$(wc -c < "$WORK_PATH/$NAME.map")
    if [ $NEW_SIZE -lt $(($OLD_SIZE * 70 / 100)) ]; then
      echo "$WORK_PATH/$NAME.map creation is significantly smaller."
    else
      mv "$WORK_PATH/$NAME.map" "$MAPS_PATH/$NAME.map"
    fi
  else
    mv "$WORK_PATH/$NAME.map" "$MAPS_PATH/$NAME.map"
  fi

fi

# ========== POI ==========

if [ "$POI_CREATION" = "true" ]; then

  # POI writer

  CMD="$OSMOSIS_HOME/osmosis --rb file=$WORK_PATH/$NAME-latest.osm.pbf \
                                 --pw file=$WORK_PATH/$NAME.poi \
                                      comment=\"$COMMENT\" \
                                      progress-logs=$PROGRESS_LOGS"
  [ $POI_TAG_CONF_FILE ] && CMD="$CMD tag-conf-file=$POI_TAG_CONF_FILE"
  echo $CMD
  eval "$CMD" || exit 1

  # Move

  mv "$WORK_PATH/$NAME.poi" "$POIS_PATH/$NAME.poi"

fi

# ========== Graph ==========

if [ "$GRAPH_CREATION" = "true" ]; then

  # Graph writer

  CMD="java $JAVACMD_OPTIONS \
            -Ddw.graphhopper.datareader.file=$WORK_PATH/$NAME-latest.osm.pbf \
            -Ddw.graphhopper.graph.location=$WORK_PATH/$NAME \
            -jar $GRAPHHOPPER_FILE \
            import \
            $GRAPHHOPPER_CONFIG"
  echo $CMD
  eval "$CMD" || exit 1

  # Zip

  cd "$WORK_PATH" && zip -r "$GRAPHS_PATH/$NAME.zip" "$NAME" && cd -

fi

# Post-process

rm -rf "$WORK_PATH"
