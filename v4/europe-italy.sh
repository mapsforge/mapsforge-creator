#!/bin/bash

cd "$(dirname "$0")"

../map-creator.sh europe/italy/centro ram en,de,fr,es
../map-creator.sh europe/italy/isole ram en,de,fr,es
../map-creator.sh europe/italy/nord-est ram en,de,fr,es
../map-creator.sh europe/italy/nord-ovest ram en,de,fr,es
../map-creator.sh europe/italy/sud ram en,de,fr,es
