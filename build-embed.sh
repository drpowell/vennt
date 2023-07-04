#!/bin/sh

# Exit if any command fails
set -e

case "$1" in
    local)
        url='./'
        echo "Building LOCAL, ensure you run ./build.sh dev"
        echo "You will need build/css/*  and build/js/*.js"
        ;;
    local-srv)
        url='http://localhost:8000/'
        echo "Building LOCAL, ensure you run ./build.sh dev"
        ;;
    remote)
        url='https://drpowell.github.io/vennt/dist/'
        ;;
    *)
      echo "Usage: ./build-embed.sh local|local-srv|remote"
      exit 1
      ;;
esac

ver=$(grep ver app/version.coffee | sed -e 's/^.* = //')
ver="${ver//\'}"

echo "Building v$ver.  Using URL $url"

if [ -z "$ver" ]; then
  echo "Version not found!"
  exit 1
fi

sed -e "s|'\./|'$url|" index.html > xx.html



sed -e "/HTML-HERE/r xx.html" \
    -e '/HTML-HERE/d' \
    -e "s/VERSION-HERE/$ver/g" embed.py > build/vennt.py

rm -f xx.html

echo "Built: build/vennt.py"


