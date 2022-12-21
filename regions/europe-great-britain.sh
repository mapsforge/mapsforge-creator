#!/bin/bash

cd "$(dirname "$0")"

../map-creator.sh europe/great-britain/england ram en,de,fr,es
../map-creator.sh europe/great-britain/scotland ram en,de,fr,es
../map-creator.sh europe/great-britain/wales ram en,de,fr,es
