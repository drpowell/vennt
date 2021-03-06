#!/bin/sh

set -e

rm -rf build
mkdir build

cp -r css/images build
cp index.html build

echo "Combining css and minifying..."
cat css/bootstrap-tour.min.css css/dge.css css/venn.css css/slick.grid.css | cleancss > build/main.min.css

echo "Compiling CoffeeScript and bundling all js..."
browserify -t coffeeify -t hbsfy app/main.coffee > build/main.big.js 

if [ "$1" = "local" ]; then
  echo "Using unminified js"
  mv  build/main.big.js build/main.js
else
  echo "Minifying js"
  uglifyjs build/main.big.js > build/main.js
  rm build/main.big.js
fi
