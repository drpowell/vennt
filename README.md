# DGE-venn

* Venn diagrams for DGE lists



## Development

### To build

    npm install -g browserify
    npm install -g clean-css
    npm install hbsfy
    npm install handlebars-runtime
    npm install coffeeify       # Needs to be local?

    browserify -t coffeeify -t hbsfy app/main.coffee | uglifyjs > main.js
    cat css/dge.css css/venn.css css/slick.grid.css | cleancss > main.min.css

### For development

    npm install -g watchify

    watchify -t coffeeify --debug app/main.coffee -o main.js -v


