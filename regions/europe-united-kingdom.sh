#!/bin/bash

cd "$(dirname "$0")"

../map-creator.sh europe/united-kingdom/england ram en,nl,fr,de,it,es
../map-creator.sh europe/united-kingdom/scotland ram en,nl,fr,de,it,es
../map-creator.sh europe/united-kingdom/wales ram en,nl,fr,de,it,es
