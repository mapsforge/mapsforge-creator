#!/bin/bash

# Mapsforge map creation (with coastlines)
# using OpenStreetMap data from Geofabrik
#
# https://github.com/mapsforge/mapsforge/blob/master/docs/MapCreation.md
#
# Written by devemux86

# Configuration

# https://wiki.openstreetmap.org/wiki/Osmosis
[ $OSMOSIS_HOME ] || OSMOSIS_HOME="$HOME/programs/osmosis"

[ $DATA_PATH ] || DATA_PATH="$HOME/mapsforge/data"

[ $MAPS_PATH ] || MAPS_PATH="$HOME/mapsforge/maps"

[ $POIS_PATH ] || POIS_PATH="$HOME/mapsforge/pois"

[ $GRAPHS_PATH ] || GRAPHS_PATH="$HOME/mapsforge/graphs"

[ $GRAPHHOPPER_HOME ] || GRAPHHOPPER_HOME="$HOME/programs/graphhopper"

[ $PROGRESS_LOGS ] || PROGRESS_LOGS="true"

[ $TAG_VALUES ] || TAG_VALUES="false"

[ $COMMENT ] || COMMENT="Map data (c) OpenStreetMap contributors"

[ $DAYS ] || DAYS="30"

[ $SKIP_MAP_CREATION ] || SKIP_MAP_CREATION="false"

[ $SKIP_POI_CREATION ] || SKIP_POI_CREATION="false"

[ $SKIP_GRAPH_CREATION ] || SKIP_GRAPH_CREATION="true"

# =========== DO NOT CHANGE AFTER THIS LINE. ===========================
# Below here is regular code, part of the file. This is not designed to
# be modified by users.
# ======================================================================

if [ $# != 1 ] && [ $# != 4 ]; then
  echo "Usage: $0 continent/country[/region] [ram|hd] [lang1,...,langN] [1|...|N]"
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

# Check map date

if [ -f "$MAPS_PATH/$NAME.map" ]; then
  if [ $(find "$MAPS_PATH/$NAME.map" -mtime -$DAYS) ]; then
    echo "$MAPS_PATH/$NAME.map exists and is newer than $DAYS days."
    exit
  fi
fi

# Pre-process

rm -rf "$WORK_PATH"
mkdir -p "$WORK_PATH"

if [ "$SKIP_MAP_CREATION" != "true" ]; then
  mkdir -p "$MAPS_PATH"
fi

if [ "$SKIP_POI_CREATION" != "true" ]; then
  mkdir -p "$POIS_PATH"
fi

if [ "$SKIP_GRAPH_CREATION" != "true" ]; then
  mkdir -p "$GRAPHS_PATH"
fi

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

# Download data

echo "Downloading $1..."
wget -nv -N -P "$WORK_PATH" https://download.geofabrik.de/$1-latest.osm.pbf || exit 1
wget -nv -N -P "$WORK_PATH" https://download.geofabrik.de/$1-latest.osm.pbf.md5 || exit 1
(cd "$WORK_PATH" && exec md5sum -c "$NAME-latest.osm.pbf.md5") || exit 1
wget -nv -N -P "$WORK_PATH" https://download.geofabrik.de/$1.poly || exit 1

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
python shape2osm.py -l "$WORK_PATH/land" "$WORK_PATH/land.shp"

# Sea

cp sea.osm "$WORK_PATH"
sed -i "s/\$BOTTOM/$BOTTOM/g" "$WORK_PATH/sea.osm"
sed -i "s/\$LEFT/$LEFT/g" "$WORK_PATH/sea.osm"
sed -i "s/\$TOP/$TOP/g" "$WORK_PATH/sea.osm"
sed -i "s/\$RIGHT/$RIGHT/g" "$WORK_PATH/sea.osm"

# Merge

CMD="$OSMOSIS_HOME/bin/osmosis --rb file=$WORK_PATH/$NAME-latest.osm.pbf \
                               --rx file=$WORK_PATH/sea.osm --s --m"
for f in $WORK_PATH/land*.osm; do
  CMD="$CMD --rx file=$f --s --m"
done
CMD="$CMD --wb file=$WORK_PATH/merge.pbf omitmetadata=true"
echo $CMD
$CMD

# Map

if [ "$SKIP_MAP_CREATION" != "true" ]; then
  CMD="$OSMOSIS_HOME/bin/osmosis --rb file=$WORK_PATH/merge.pbf"
  [ $MAP_TRANSFORM_FILE ] && CMD="$CMD --tt file=$MAP_TRANSFORM_FILE"
  CMD="$CMD --mw file=$WORK_PATH/$NAME.map \
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
      exit 1
    fi
  fi
  mv "$WORK_PATH/$NAME.map" "$MAPS_PATH/$NAME.map"
fi

# POI

if [ "$SKIP_POI_CREATION" != "true" ]; then
  CMD="$OSMOSIS_HOME/bin/osmosis --rb file=$WORK_PATH/$NAME-latest.osm.pbf \
                                 --pw file=$WORK_PATH/$NAME.poi \
                                      comment=\"$COMMENT\" \
                                      progress-logs=$PROGRESS_LOGS"
  [ $POI_TAG_CONF_FILE ] && CMD="$CMD tag-conf-file=$POI_TAG_CONF_FILE"
  echo $CMD
  eval "$CMD" || exit 1
  mv "$WORK_PATH/$NAME.poi" "$POIS_PATH/$NAME.poi"
fi

# Graph

if [ "$SKIP_GRAPH_CREATION" != "true" ]; then
  CMD="java $JAVACMD_OPTIONS \
            -Dgraphhopper.datareader.file=$WORK_PATH/$NAME-latest.osm.pbf \
            -Dgraphhopper.graph.location=$WORK_PATH/$NAME \
            -jar $GRAPHHOPPER_HOME/graphhopper.jar \
            import \
            $GRAPHHOPPER_HOME/config.yml"
  echo $CMD
  eval "$CMD" || exit 1
  cd "$WORK_PATH" && zip -r "$GRAPHS_PATH/$NAME.zip" "$NAME" && cd -
fi

# Post-process

rm -rf "$WORK_PATH"
