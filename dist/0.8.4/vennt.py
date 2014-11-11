#!/usr/bin/env python

import argparse
import json
import re
import sys,os
import csv, StringIO

bigFC = 100

version = '0.8.4'

def error(message):
    sys.stderr.write("Error: %s\n" % message)
    sys.exit(1)

def embed(csv, args):
    html="""
<html>
  <head>

    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" />
    <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/ui-lightness/jquery-ui.min.css" />

    <link rel="stylesheet" type="text/css" href='http://drpowell.github.io/vennt/dist/main.min.css'>
    <script type="text/javascript" src='http://drpowell.github.io/vennt/dist/main.js'></script>
  </head>

  <body>
    <script type="text/javascript">
      window.venn_settings = { };
    </script>

    <div id='loading'><img src='http://drpowell.github.io/vennt/dist/images/ajax-loader.gif'></div>
  </body>
</html>

         """
    enc = json.dumps(csv)
    settings = ("window.venn_settings = {html_version: '%s',"
                "key_column: %s, id_column: %s, fdr_column: %s,"
                "logFC_column: %s, info_columns: %s, csv_data: data};")%(version,
                  json.dumps(args.key), json.dumps(args.id), json.dumps(args.fdr),
                  json.dumps(args.logFC), json.dumps(args.info))
    return html.replace('window.venn_settings = { };', "var data=%s;\n\n%s"%(enc,settings), 1)

def combine_csv(files,key, delim):
    data = []
    sys.stderr.write("Using a separate CSV files\n")
    si = StringIO.StringIO()
    cw = csv.writer(si, delimiter=",")
    first = True
    for f in files:
        sys.stderr.write("  Reading : %s\n"%f)
        with open(f, 'rb') as fopen:
            reader = csv.reader(fopen, delimiter=delim)

            headers = reader.next()
            if first:
                cw.writerow(headers + ['key'])
                first=False

            k = os.path.splitext(os.path.basename(f))[0]
            for r in reader:
                cw.writerow(r+[k])

    return si.getvalue()

def cuffdiff_process(f):
    with open(f, 'r') as csvfile:
        reader = csv.reader(csvfile, delimiter="\t")
        si = StringIO.StringIO()
        cw = csv.writer(si, delimiter=",")

        headers = reader.next()
        cw.writerow(headers + ['key'])
        idx1 = headers.index("sample_1")
        idx2 = headers.index("sample_2")
        fcIdx = headers.index("log2(fold_change)")
        for r in reader:
            # Replace an infinite fold-change with something vennt can handle
            if r[fcIdx] == 'inf':
                r[fcIdx] = bigFC
            if r[fcIdx] == '-inf':
                r[fcIdx] = -bigFC
            k = r[idx1] + ' vs ' + r[idx2]
            cw.writerow(r + [k])

        return si.getvalue()

def venn(args):

    if args.tab:
        args.tab = '\t'
    else:
        args.tab = ','

    if args.csvfile_old is not None:
        args.csvfile = args.csvfile_old

    #print args

    csv_data = None
    if args.csvfile == '-':
        sys.stderr.write("Reading from stdin...\n")
        csv_data = sys.stdin.read()
    elif len( args.csvfile ) == 1:
        if args.cuffdiff:
            csv_data = cuffdiff_process( args.csvfile[0] )
            args.id  = 'test_id'
            args.fdr = 'q_value'
            args.logFC = 'log2(fold_change)'
            args.info = ['gene_id','gene']
        else:
            sys.stderr.write("Using a single CSV file with the key column '%s'\n"%(args.key))

            with open(args.csvfile[0], 'rb') as infile:
                reader = csv.reader( infile, delimiter=args.tab)
                sio = StringIO.StringIO()
                cw = csv.writer(sio, delimiter=',', quoting=csv.QUOTE_MINIMAL)
                cw.writerows( reader )
            csv_data = sio.getvalue()
    else:
        if args.cuffdiff:
            error("Only 1 file (gene_exp.diff) expected when using --cuffdiff")
        csv_data = combine_csv(args.csvfile, args.key, args.tab)

    return embed( csv_data, args )


def arguments():
    parser = argparse.ArgumentParser(description='Produce a standalone Vennt html file from a CSV file containing gene-lists.  You may use a single CSV file containing all the gene lists - in which case you should have a "key" column specifying the gene lists.  Alternatively, you can use separate CSV files for each gene list then a "key" column will be created based on the filenames.  With separate CSV files they are expected to be in the same format with the same column names in the same column order.')
    parser.add_argument('--version', action='version', version=version)
    parser.add_argument('csvfile',
                        nargs='*', default='-',
                        help="CSV file to process (default stdin).  Multiple files may be specified - in which case it is assumed each file contains one gene list and the filenames will be used to create a 'key' column")
    parser.add_argument('--csvfile', dest='csvfile_old',
                        nargs='*', metavar='CSVFILE',
                        help="Like positional csvfile above.  For backward compatibility")
    parser.add_argument('-o','--out', type=argparse.FileType('w'),
                        default='-',
                        help="Output file (default stdout)")
    parser.add_argument('--key', default='key',
                        help='Name for "key" column in CSV file (default "key").  Ignored if using multiple CSV files.')
    parser.add_argument('--id', default='Feature',
                        help='Name for "id" column in CSV file (default "Feature")')
    parser.add_argument('--fdr', default='adj.P.Val',
                        help='Name for "FDR" column in CSV file (default "adj.P.Val")')
    parser.add_argument('--logFC', default='logFC',
                        help='Name for "logFC" column in CSV file (default "logFC")')
    parser.add_argument('--info', default=['Feature'], nargs='*',
                        help='Names for info columns in CSV file - accepts multiple strings (default "Feature")')
    parser.add_argument('--cuffdiff', action='store_true', default=False,
                        help='Input file is from cuffdiff (gene_exp.diff).  Other options will be ignored')
    parser.add_argument('--tab', action='store_true', default=False,
                        help='TAB separated input file?')


    return parser

if __name__ == '__main__':
    parser = arguments()
    args = parser.parse_args()
    args.out.write( venn( args ) )
