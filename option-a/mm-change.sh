#!/bin/sh

for i in mm1 mm2 mm3 mm4; do
    do-forked.pl $i.txt $i
done
