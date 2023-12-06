[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](http://www.gnu.org/licenses/lgpl-3.0)

# mapsforge-creator fork by AntonioLagoD

Automatic generation for Mapsforge maps / pois (based on our [guide](https://github.com/mapsforge/mapsforge/blob/master/docs/MapCreation.md)) and GraphHopper graphs.

- First aks if you want to download and merge contour lines from https://osmscout.karry.cz/countours/phyghtmap-osm-contours/ .  

- The script downloads OpenStreetMap data from [Geofabrik](https://download.geofabrik.de/) and land polygons from [OpenStreetMap Data](https://osmdata.openstreetmap.de/).
- You will need a working [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) installation.
- You may need a working [GraphHopper 1.0](https://github.com/graphhopper/graphhopper/tree/1.0) installation ([graphhopper-web-1.0.jar](https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web/1.0/) and [config.yml](https://github.com/mapsforge/mapsforge-creator/blob/master/config.yml)).
- Download the **map-writer** and **poi-writer** plugins (**jar-with-dependencies**), either their release version from [Maven Central](https://repo1.maven.org/maven2/org/mapsforge/) or their snapshot version from [Sonatype OSS Repository Hosting](https://oss.sonatype.org/content/repositories/snapshots/org/mapsforge/). See the Osmosis [documentation](https://wiki.openstreetmap.org/wiki/Osmosis/Detailed_Usage#Plugin_Tasks) for how to properly install them.
- You could increase the Java heap space that may be allocated for Osmosis and GraphHopper. You can do so by setting the global variable `JAVACMD_OPTIONS=-Xmx1024M`. This sets the maximum available Java heap space to 1024MB. Of course you can set this parameter to a value which fits best for your purpose.
- Requirements are working installations of: [GDAL](https://gdal.org/), [Java](https://www.java.com/), [Perl](https://www.perl.org/), [Python 3.x](https://www.python.org/) with GDAL, Zip.
- The script has some config specifications in `Configuration` section at the top. Adjust them to your environment: Osmosis, GraphHopper, data/output paths, etc. Or can set externally the relevant variables.
- Run example:  './map-creator.sh europe/spain hd es,en '
