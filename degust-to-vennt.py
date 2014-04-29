#!/usr/bin/env python

import csv,sys,os

os.mkdir('out')

for f in sys.argv[1:]:
  with open(f, 'r') as csvfile:
    with open('out/' + os.path.basename(f), 'w') as out:
      reader = csv.reader(csvfile, delimiter=",")
      cw = csv.writer(out, delimiter=",")
      headers = reader.next()
      cw.writerow([headers[0], "logFC", headers[3]])
      for r in reader:
        cw.writerow([r[i] for i in [0,2,3]])

print "Now run:"
print "  (cd out ; python vennt.py --fdr FDR %s > out.html)"%(" ".join([os.path.basename(x) for x in sys.argv[1:]]))
