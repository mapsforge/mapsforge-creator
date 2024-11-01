#!/bin/bash

cd "$(dirname "$0")"

../map-creator.sh europe/united-kingdom/england ram en,de,fr,es
../map-creator.sh europe/united-kingdom/scotland ram en,de,fr,es
../map-creator.sh europe/united-kingdom/wales ram en,de,fr,es
