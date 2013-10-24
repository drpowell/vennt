#!/bin/sh


rm -rf build
mkdir build

cp index.html build
browserify -t coffeeify -t hbsfy app/main.coffee | uglifyjs > build/main.js
cat css/dge.css css/venn.css css/lib/slick.grid.css | cleancss > build/main.min.css
