#!/usr/bin/env python

import argparse
import json
import re
import sys,os


def embed(csv, args):
    html="""
           HTML-HERE
         """
    enc = json.dumps(csv)
    settings = ("window.venn_settings = {key_column: %s, id_column: %s, fdr_column: %s,"
                "logFC_column: %s, info_columns: %s, csv_data: data};")%(
                  json.dumps(args.key), json.dumps(args.id), json.dumps(args.fdr),
                  json.dumps(args.logFC), json.dumps(args.info))
    s = html.replace('window.venn_settings = { };', "var data=%s;\n\n%s"%(enc,settings), 1)
    return s



parser = argparse.ArgumentParser(description='Produce a standalone Vennt html file from a CSV file containing gene-lists.  You may use a single CSV file containing all the gene lists - in which case you should have a "key" column specifying the gene lists.  Alternatively, you can use separate CSV files for each gene list then a "key" column will be created based on the filenames.  With separate CSV files they are expected to be in the same format with the same column names in the same column order.')
parser.add_argument('csvfile',
                    nargs='*', default='-', 
                    help="CSV file to process (default stdin).  Multiple files may be specified - in which case it is assumed each file contains one gene list and the filenames will be used to create a 'key' column")
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

args = parser.parse_args()

#print args

csv = None
if args.csvfile == '-':
    sys.stderr.write("Reading from stdin...\n")
    csv = sys.stdin.read()
elif len(args.csvfile)==1:
    sys.stderr.write("Using a single CSV file with the key column '%s'\n"%(args.key))
    csv = open(args.csvfile[0],'r').read()
else:
    data = []
    sys.stderr.write("Using a separate CSV files\n")
    for f in args.csvfile:
        sys.stderr.write("  Reading : %s\n"%f)
        d = open(f).read()
        # Separate header (and keep if it is the first)
        hdr, d = d.split("\n",1)
        if len(data)==0:
            data.append('"%s",'%(args.key)+hdr+"\n")
        d = re.sub(r'^(.{2})',r'"%s",\1'%os.path.splitext(os.path.basename(f))[0], d, 0, re.MULTILINE)   # Add a key column to all rows
        data.append(d)

    csv = ''.join(data)

args.out.write(embed(csv, args))
