#!/bin/sh

ver=$1

if [ -z "$ver" ]; then
  echo "Version not supplied!"
  exit 1
fi

mkdir -p dist/$ver
cp -r build/* dist/$ver

cd dist
for f in $ver/*; do
  cp -rf $f .
done
