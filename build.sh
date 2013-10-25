#!/bin/sh

rm -rf build
mkdir build

cp -r css/images build

sed -e "s|'\./|'$url|" index.html > build/index.html

browserify -t coffeeify -t hbsfy app/main.coffee | uglifyjs > build/main.js
cat css/dge.css css/venn.css css/slick.grid.css | cleancss > build/main.min.css
