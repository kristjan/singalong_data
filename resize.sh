#!/bin/bash

mkdir -p out/types/photos/resized

echo -n "Resizing files "

for OLD in out/types/photos/images/*.jpg
do
	NEW=out/types/photos/resized/`basename $OLD`

	convert $OLD -resize 256x256^ -gravity center -extent 256x256 $NEW

	echo -n .
done
