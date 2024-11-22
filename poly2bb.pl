#!/usr/bin/perl

# script to extract a polygon file's bbox
# output is in a form suitable for the Mapsforge map-writer "bbox" option

# written by Frederik Ramm <frederik@remote.org>, public domain
# adapted by devemux86

$maxx[0] = -360;
$maxy[0] = -360;
$minx[0] = 360;
$miny[0] = 360;
$area = -1;

while(<>) {
    if (/^\d+$/) {
        $area++;
        $maxx[$area] = -360;
        $maxy[$area] = -360;
        $minx[$area] = 360;
        $miny[$area] = 360;
    } elsif (/^\s+([0-9.E+-]+)\s+([0-9.E+-]+)\s*$/) {
        my ($x, $y) = ($1, $2);
        $maxx[$area] = $x if ($x > $maxx[$area]);
        $maxy[$area] = $y if ($y > $maxy[$area]);
        $minx[$area] = $x if ($x < $minx[$area]);
        $miny[$area] = $y if ($y < $miny[$area]);
    }
}

if ($area > 0) {
    $west = 0;
    for (my $i = 0; $i <= $area; $i++) {
        if ($minx[$i] > 0 && $maxx[$i] > 0) {
            $west = 1;
            last;
        }
    }
    $east = 0;
    for (my $i = 0; $i <= $area; $i++) {
        if ($minx[$i] < 0 && $maxx[$i] < 0) {
            $east = 1;
            last;
        }
    }
    if ($west == 0 || $east == 0) {
        for (my $i = 0; $i <= $area; $i++) {
            $maxx[0] = $maxx[$i] if ($maxx[$i] > $maxx[0]);
            $maxy[0] = $maxy[$i] if ($maxy[$i] > $maxy[0]);
            $minx[0] = $minx[$i] if ($minx[$i] < $minx[0]);
            $miny[0] = $miny[$i] if ($miny[$i] < $miny[0]);
        }
        $area = 0;
    }
}

$buffer = 0.1;
for (my $i = 0; $i <= $area; $i++) {
    $miny[$i] = $miny[$i] - $buffer;
    $miny[$i] = $miny[$i] < -90 ? -90 : $miny[$i];
    $minx[$i] = $minx[$i] - $buffer;
    $minx[$i] = $minx[$i] < -180 ? -180 : $minx[$i];
    $maxy[$i] = $maxy[$i] + $buffer;
    $maxy[$i] = $maxy[$i] > 90 ? 90 : $maxy[$i];
    $maxx[$i] = $maxx[$i] + $buffer;
    $maxx[$i] = $maxx[$i] > 180 ? 180 : $maxx[$i];
    printf "%f,%f,%f,%f\n", $miny[$i], $minx[$i], $maxy[$i], $maxx[$i];
}
