#!/usr/bin/env bash
# Descargar icams inside folder
# P. Espin
# This script extracts final folder names and processes each using icams_one_epoch.sh.

# Get the current and parent directory names
parent_dir=$(basename "$(dirname "$(pwd)")")
current_dir=$(basename "$(pwd)")

# Extract and process the identifier from the current directory name
tr=$(echo "$current_dir" | cut -d '_' -f1 | sed 's/^0*//' | rev | cut -c 2- | rev)

# Ensure old lista.txt is removed before creating a new one
[ -f "lista.txt" ] && rm -f "lista.txt"

# Define paths
base_dir="/gws/nopw/j04/nceo_geohazards_vol1/public"
path="$base_dir/LiCSAR_products/$tr/$current_dir/epochs/2025"*

# Enable nullglob to avoid literal '*' if no match
shopt -s nullglob
files=( $path )
shopt -u nullglob

# Fallback to .future if nothing found
if [ ${#files[@]} -eq 0 ]; then
    path="$base_dir/LiCSAR_products.future/$tr/$current_dir/epochs/2025"*
    shopt -s nullglob
    files=( $path )
    shopt -u nullglob
fi

# If still nothing found, exit with error
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No matching epochs directories found in LiCSAR_products or LiCSAR_products.future."
    exit 1
fi

# Write only the final folder names to lista.txt
for f in "${files[@]}"; do
    echo "${f##*/}"
done > lista.txt

mkdir log_ERA5

# Process each folder listed in lista.txt
while read -r line; do
    echo -e "$line"
    sbatch --qos=high \
           --output=log_ERA5/ICAMS_${line}_${current_dir}.out \
           --error=log_ERA5/ICAMS_${line}_${current_dir}.err \
           --job-name=ICAMS_${line}_${current_dir} \
           -n 8 --time=23:59:00 --mem=65536 \
           -p comet --account=comet_lics --partition=standard \
           --wrap="./descargar_icam.sh"
done < lista.txt
