#!/usr/bin/perl

# script to extract a polygon file's bbox
# output is in a form suitable for the Mapsforge map-writer "bbox" option

# written by Frederik Ramm <frederik@remote.org>, public domain
# adapted by devemux86

$maxx = -360;
$maxy = -360;
$minx = 360;
$miny = 360;

open(f, $ARGV[0]);

while(<f>)
{
   if (/^\s+([0-9.E+-]+)\s+([0-9.E+-]+)\s*$/)
   {
       my ($x, $y) = ($1, $2);
       $maxx = $x if ($x>$maxx);
       $maxy = $y if ($y>$maxy);
       $minx = $x if ($x<$minx);
       $miny = $y if ($y<$miny);
   }
}
close($ARGV[0]);

$buffer = $ARGV[1];
$miny = $miny - $buffer;
$miny = $miny < -90 ? -90 : $miny;
$minx = $minx - $buffer;
$minx = $minx < -180 ? -180 : $minx;
$maxy = $maxy + $buffer;
$maxy = $maxy > 90 ? 90 : $maxy;
$maxx = $maxx + $buffer;
$maxx = $maxx > 180 ? 180 : $maxx;
printf "%f,%f,%f,%f\n", $miny, $minx, $maxy, $maxx;
