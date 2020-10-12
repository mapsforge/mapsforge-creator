"""
This script is to convert multipolygon to single polygons.
A input shapefile is assuming trimed land-polygons file
by ogr2ogr like map-creator script.

ogr2ogr may create some polygons in one feature trimed by
bounding box. For example one polygon that looks like
alphabet 'U' divides to two part above horizontal center line.
And in map-creator shape2osm after ogr2ogr called doesn't
write these polygon to osm file.

This script rewrited with reference to the following sites.

https://lists.osgeo.org/pipermail/gdal-dev/2010-December/027041.html
https://pcjericks.github.io/py-gdalogr-cookbook/index.html

"""
import os
import sys

try:
    from osgeo import ogr
except ImportError:
    print("ogr import failed", file=sys.stderr)
    sys.exit(1)

DRIVER_NAME = "ESRI Shapefile"


def copy_polygon(src_geom, dst_layer):
    "copy geometry part to destination layer"

    feature = ogr.Feature(dst_layer.GetLayerDefn())
    feature.SetGeometry(src_geom.Clone())
    dst_layer.CreateFeature(feature)

def split_polygon(src_geom, dst_layer):
    "split plural polygons in a multipolygon to polygons"

    for i in range(src_geom.GetGeometryCount()):
        child_geom = src_geom.GetGeometryRef(i)
        copy_polygon(child_geom, dst_layer)

def multipolygon2polygons(src_layer, dst_layer):
    "convert multipolygon to single polygons"

    for i in range(src_layer.GetFeatureCount()):
        feature = src_layer.GetFeature(i)
        geom = feature.GetGeometryRef()

        if geom.GetGeometryType() == ogr.wkbMultiPolygon:
            split_polygon(geom, dst_layer)
        else:
            copy_polygon(geom, dst_layer)


if __name__ == '__main__':

    import argparse

    parser = argparse.ArgumentParser(description="convert multipolygon to single polygons")
    parser.add_argument("src", type=str, help="source shape file")
    parser.add_argument("dst", type=str, help="destination shape file")
    args = parser.parse_args()

    driver = ogr.GetDriverByName(DRIVER_NAME)

    # source layer
    src = driver.Open(args.src, 0)
    if not src:
        print("file cann't open %s" % args.src, file=sys.stderr)
    srcLayer = src.GetLayer(0)

    # destination layer
    if os.path.exists(args.dst):
        driver.DeleteDataSource(args.dst)

    dst = driver.CreateDataSource(args.dst)
    dst_layer_name = os.path.splitext(os.path.basename(args.dst))[0]
    dstLayer = dst.CreateLayer(dst_layer_name, geom_type=ogr.wkbPolygon)

    # split
    multipolygon2polygons(srcLayer, dstLayer)
