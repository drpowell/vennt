#!/usr/bin/env python

import argparse
import json
import re
import sys


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
    settings = ("window.venn_settings = {key_column: %s, id_column: %s, fdr_column: %s,"
                "logFC_column: %s, info_columns: %s, csv_data: data};")%(
                  json.dumps(args.key), json.dumps(args.id), json.dumps(args.fdr),
                  json.dumps(args.logFC), json.dumps(args.info))
    s = html.replace('window.venn_settings = { };', "var data=%s;\n\n%s"%(enc,settings), 1)
    return s



parser = argparse.ArgumentParser(description='Produce a standalone Vennt html file from a CSV file containing gene-lists.')
parser.add_argument('csvfile', type=argparse.FileType('r'), 
                    nargs='?', default='-', 
                    help="CSV file to process (default stdin)")
parser.add_argument('-o','--out', type=argparse.FileType('w'), 
                    default='-', 
                    help="Output file (default stdout)")
parser.add_argument('--key', default='key', 
                    help='Name for "key" column in CSV file (default "key")')
parser.add_argument('--id', default='Feature', 
                    help='Name for "id" column in CSV file (default "Feature")')
parser.add_argument('--fdr', default='adj.P.Val', 
                    help='Name for "FDR" column in CSV file (default "adj.P.Val")')
parser.add_argument('--logFC', default='logFC', 
                    help='Name for "logFC" column in CSV file (default "logFC")')
parser.add_argument('--info', default=['Feature'], nargs='*',
                    help='Names for info columns in CSV file - accepts multiple strings (default "Feature")')

args = parser.parse_args()

#print args

if args.csvfile == sys.stdin:
    sys.stderr.write("Reading from stdin...\n")

csv = args.csvfile.read()

args.out.write(embed(csv, args))

