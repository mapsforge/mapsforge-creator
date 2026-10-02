#!/bin/bash

cd "$(dirname "$0")"

../map-creator.sh europe/italy/centro ram en,nl,fr,de,it,es
../map-creator.sh europe/italy/isole ram en,nl,fr,de,it,es
../map-creator.sh europe/italy/nord-est ram en,nl,fr,de,it,es
../map-creator.sh europe/italy/nord-ovest ram en,nl,fr,de,it,es
../map-creator.sh europe/italy/sud ram en,nl,fr,de,it,es
