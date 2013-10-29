#!/bin/sh

set -e

rm -rf build
mkdir build

cp -r css/images build
cp index.html build
cp embed.py build

echo "Combining css and minifying..."
cat css/bootstrap-tour.min.css css/dge.css css/venn.css css/slick.grid.css | cleancss > build/main.min.css

echo "Compiling CoffeeScript and bundling all js..."
browserify -t coffeeify -t hbsfy app/main.coffee > build/main.big.js 
echo "Minifying js..."
uglifyjs build/main.big.js > build/main.js
rm build/main.big.js

