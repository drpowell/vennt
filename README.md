# Vennt

* Dynamic Venn diagrams for differential gene expression

## Example Screenshot

![Vennt screenshot](http://drpowell.github.io/vennt/images/screenshot-1.png)

## To use

To use, generate a single CSV file with all your gene lists.  Each row of the CSV should contain information about a gene including the `log fold change`, and the `adjust p-value`.  Use a single column to specify the gene-list (see the example below).  Each gene must have a unique identifier, which is used to find the corresponding genes in the different gene lists.

Download this <a href='http://drpowell.github.io/vennt/example/template.html'>html file</a>.  Then, just put it and your CSV file on a web-server.  (For local testing you can use `python -mSimpleHTTPServer`.)

You may need to specify some configuration if the defaults do not suffice, for example column names.  These are configured in the html file.

#### Available settings

Set these in `window.venn_settings` in your html file.

* `csv_file`  - (default 'data.csv') Name of the CSV file containing the data to load.  Must be on the same origin as the html file due to javascript's [Same-origin policy](http://en.wikipedia.org/wiki/Same-origin_policy) 
* `csv_data` - (default 'null') - This can be used to directly embed a CSV file rather than requesting via ajax.  Note, setting this parameter will cause any `csv_file` to be ignored
* `key_column` - (default 'key') Name of the column specifying the gene-list.
* `id_column` - (default 'Feature') Name of the column specifying a unique identifier for the gene.  This must be unique within each gene-list, because it is used to match up the genes between the different gene-lists.
* `fdr_column` - (default 'adj.P.Val') - Name of the column containing the adjusted p-value.  (This is often a false-discovery rate.)
* `logFC_column` - (default 'logFC') - Name of the column containing the log-fold-change for each gene-list.
* `info_columns` - (default '[Feature]') - An array of column names to display to the user.  This should contain useful information you want the user to see - such as a gene-id, perhaps common gene-name, or possibly a brief description.
* `show_tour` - (default true) - Show the Venn tour on page load (if not shown before)

For example, consider this is your csv file, which is called `data.csv`:

    gene-list,id,Description,Gene Name,logFC,adj.P.Val
    WT vs MT1,ENSG00000083520,DIS3 mitotic control homolog (S. cerevisiae),DIS3,-2.4,4.8e-10
    WT vs MT1,ENSG00000025156,heat shock transcription factor 2,HSF2,-0.89,6.4e-05
    WT vs MT1,ENSG00000103042,"solute carrier family 38, member 7",SLC38A7,1.5,6.4e-05
    WT vs MT2,ENSG00000083520,DIS3 mitotic control homolog (S. cerevisiae),DIS3,-2.4,4.8e-10
    WT vs MT2,ENSG00000025156,heat shock transcription factor 2,HSF2,-0.89,6.4e-05
    WT vs MT2,ENSG00000103042,"solute carrier family 38, member 7",SLC38A7,1.5,6.4e-05

You'd specify this in your html file:

    window.venn_settings = { csv_file: 'data.csv',
                             key_column: 'gene-list',
                             id_column: 'id'
                             info_columns: ['id', 'Description', 'Gene Name']
                           }


## Development

### To build 
For building from sources, you will need nodejs and the following modules.

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
    (cd build ; python -mSimpleHTTPServer)

