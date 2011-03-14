#! /usr/bin/env bash

GNUPLOT=/space/hanlon/programs/gnuplot-4.4.0/bin/gnuplot
#GNUPLOT=gnuplot
DEST=../images
FILES="results/latency-distributions/*.eps 
    results/average-latency/*.eps"

#set -x

(cd results/average-latency; $GNUPLOT average-latency.gp)
(cd results/latency-distributions; $GNUPLOT latency-distributions.gp)

# Convert each eps to pdf
for f in $FILES
do 
    if [ -f "$f" ]; then
        pathname=${f%\.*}
        name=$(basename $f)
        name=${name%\.*}
        echo "Converting $name"
        sed -i s#$name#"$DEST\/"$name.pdf#g $pathname.tex
        ps2pdf -dEPSCrop $pathname.eps
        rm $pathname.eps
        mv $pathname.tex $DEST
        mv $name.pdf $DEST
    fi
done

