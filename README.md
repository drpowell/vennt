# DGE-venn

* Venn diagrams for DGE lists



## Development

### To build

    npm install -g browserify
    npm install coffeeify       # Needs to be local?

    browserify -t coffeeify --debug app/main.coffee | uglifyjs > main.js

### For development

    npm install -g watchify

    watchify -t coffeeify --debug app/main.coffee -o main.js -v


