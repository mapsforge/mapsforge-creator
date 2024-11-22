[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](http://www.gnu.org/licenses/lgpl-3.0)

# mapsforge-creator

Automatic generation for Mapsforge maps / pois (based on our [guide](https://github.com/mapsforge/mapsforge/blob/master/docs/MapCreation.md)).

- The script downloads OpenStreetMap data from [Geofabrik](https://download.geofabrik.de/) and land polygons from [OpenStreetMap Data](https://osmdata.openstreetmap.de/).
- You will need a working [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) installation.
- Download from [Releases](https://github.com/mapsforge/mapsforge/releases) or build the snapshot **map-writer** and **poi-writer** plugins (**jar-with-dependencies**). See the Osmosis [documentation](https://wiki.openstreetmap.org/wiki/Osmosis/Detailed_Usage#Plugin_Tasks) for how to properly install them.
- You could increase the Java heap space that may be allocated for Osmosis. You can do so by setting the global variable `JAVACMD_OPTIONS=-Xmx1024M`. This sets the maximum available Java heap space to 1024MB. Of course you can set this parameter to a value which fits best for your purpose.
- Requirements are working installations of: GDAL, Java, Perl, Python 3 with Zip.
- The script has some config specifications in `Configuration` section at the top. Adjust them to your environment: Osmosis, data/output paths, etc. Or can set externally the relevant variables.
- Run `./map-creator.sh` script without arguments to see its usage.
