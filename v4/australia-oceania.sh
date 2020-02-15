#!/bin/bash

cd "$(dirname "$0")"

../map-creator.sh australia-oceania/australia hd en,de,fr,es
../map-creator.sh australia-oceania/fiji ram en,de,fr,es
../map-creator.sh australia-oceania/new-caledonia ram en,de,fr,es
../map-creator.sh australia-oceania/new-zealand ram en,de,fr,es
../map-creator.sh australia-oceania/papua-new-guinea ram en,de,fr,es
