#!/usr/bin/env python

import csv
import os
import subprocess

def download(filename):
    print "Downloading files for %s" % filename

    with open(filename, "rb") as tsv:
        tsv_reader = csv.DictReader(tsv, delimiter="\t")

        for row in tsv_reader:
            if row["Latitude"] and row["Longitude"]:
                print "Downloaded:", subprocess.call(["wget", "-q", "-O",
                    "out/types/photos/images/" + row["ID"] + ".jpg",
                    row["URL"]])

if __name__ == "__main__":
    for root, dirs, files in os.walk("out/types/photos"):
        for filename in files:
            download(os.path.join(root, filename))
