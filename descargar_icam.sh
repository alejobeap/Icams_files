#!usr/bin/env bash
# Descargar icams inside folder
#P. Espin
#file 1 is lista from example "ls /gws/nopw/j04/nceo_geohazards_vol1/public/LiCSAR_products/40/040D_09102_131313/epochs/ -1 >> lista.txt"

file=$1

while read -r line; do
    echo -e "$line"
    ./icams_one_epoch.sh $(basename "$(pwd)") $line    
done <$file

