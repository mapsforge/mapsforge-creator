[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](http://www.gnu.org/licenses/lgpl-3.0)

# mapsforge-creator

Automatic generation for Mapsforge maps / pois (based on our [guide](https://github.com/mapsforge/mapsforge/blob/master/docs/MapCreation.md)) and GraphHopper graphs.

**For the old process using planet.osm see [here](https://github.com/mapsforge/mapsforge-mapcreator).**

- The script downloads OpenStreetMap data from [Geofabrik](https://download.geofabrik.de/) and land polygons from [OpenStreetMap Data](https://osmdata.openstreetmap.de/).
- You will need a working [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) installation.
- You may need a working [GraphHopper 1.0](https://github.com/graphhopper/graphhopper/tree/1.0) installation ([graphhopper-web-1.0.jar](https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/1.0/) and [config.yml](https://github.com/mapsforge/mapsforge-creator/blob/master/config.yml)).
- Get the **map-writer** and **poi-writer** plugins (**jar-with-dependencies**). See the Osmosis [documentation](https://wiki.openstreetmap.org/wiki/Osmosis/Detailed_Usage#Plugin_Tasks) for how to properly install them.
- You could increase the Java heap space that may be allocated for Osmosis and GraphHopper. You can do so by setting the global variable `JAVACMD_OPTIONS=-Xmx1024M`. This sets the maximum available Java heap space to 1024MB. Of course you can set this parameter to a value which fits best for your purpose.
- Requirements are working installations of: [GDAL](https://gdal.org/), [Java](https://www.java.com/), [Perl](https://www.perl.org/), [Python 3.x](https://www.python.org/) with Zip.
- The script has some config specifications in `Configuration` section at the top. Adjust them to your environment: Osmosis, GraphHopper, data/output paths, etc. Or can set externally the relevant variables.
- Run `./map-creator.sh` script without arguments to see its usage.
