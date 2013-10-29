#!/bin/sh

# Exit if any command fails
set -e

url='http://drpowell.github.io/vennt/dist/'

ver=$(grep ver app/version.coffee| sed -e 's/^.* = //')
ver="${ver//\'}"

echo "Building v$ver.  Using URL $url"

if [ -z "$ver" ]; then
  echo "Version not found!"
  exit 1
fi

echo "Minifying..."
./build.sh

echo "Changing repo to gh-pages"
git checkout gh-pages

echo "Copying to dist/$ver"

mkdir -p dist/$ver
cp -r build/* dist/$ver
sed -e "s|'\./|'$url|" build/index.html > dist/$ver/index.html

sed -e "/HTML-HERE/r dist/$ver/index.html" -e '/HTML-HERE/d' build/embed.py > dist/$ver/vennt.py

(  cd dist
   for f in $ver/*; do
     cp -rf $f .
   done
)


echo "Now commit the changes and switch back:"
echo "    git add dist/$ver"
echo "    git commit -a"
echo "    git checkout master"
