# mapsforge-creator

Automatic generation for Mapsforge maps and pois (based on our [guide](https://github.com/mapsforge/mapsforge/blob/master/docs/MapCreation.md)).

**For the old process using planet.osm see [here](https://github.com/mapsforge/mapsforge-mapcreator).**

- This script downloads OpenStreetMap data from [Geofabrik](http://download.geofabrik.de/).
- You will need a working [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis) installation.
- Download the **map-writer** and **poi-writer** plugins (**jar-with-dependencies**), either their release version from [Maven Central](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.mapsforge%22) or their snapshot version from [Sonatype OSS Repository Hosting](https://oss.sonatype.org/content/repositories/snapshots/org/mapsforge/). See the Osmosis [documentation](http://wiki.openstreetmap.org/wiki/Osmosis/Detailed_Usage#Plugin_Tasks) for how to properly install them.
- You could increase the Java heap space that may be allocated for Osmosis. You can do so by editing the script `$OSMOSIS_HOME/bin/osmosis(.bat)` and insert a line with `JAVACMD_OPTIONS=-Xmx800m`. This sets the maximum available Java heap space to 800MB. Of course you can set this parameter to a value which fits best for your purpose.
- Download the [OpenStreetMap Data](http://openstreetmapdata.com/) land polygons, specifically the dataset [land-polygons-split-4326.zip](http://data.openstreetmapdata.com/land-polygons-split-4326.zip) and extract the archive.
- Requirements are working installations of: [GDAL](http://gdal.org/), [Java](https://www.java.com/), [Perl](https://www.perl.org/), [Python 2.x](https://www.python.org/) with GDAL.
- **map-creator** script has some config specifications in `# Configuration` section at the top. Adjust them to your environment: Osmosis home, land polygons path, output paths, variable tag values etc. Or can set externally the relevant variables.
- Run `./map-creator` script without arguments to see its usage.
