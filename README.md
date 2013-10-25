# Vennt

* Dynamic Venn diagrams for differential gene expression


## Development

### To build 

    npm install -g browserify
    npm install -g clean-css
    npm install hbsfy
    npm install handlebars-runtime
    npm install coffeeify       # Needs to be local?

    # Builds files index.html, main.js, main.min.css into build/
    ./build.sh

### For development
This will watch the js & coffeescript files and rebuild `main.js` as needed.  You'll still need to build the css using `build.sh`.

    npm install -g watchify

    watchify -t coffeeify -t hbsfy --debug app/main.coffee -o build/main.js -v


