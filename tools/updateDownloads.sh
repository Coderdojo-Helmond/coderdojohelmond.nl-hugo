#!/usr/bin/env bash
INPUT_DIR="./static/documents"
OUTPUT_FILE="./data/downloads.yml"
PATTERN="*static" 

echo "files:" > "$OUTPUT_FILE"

for f in $(find $INPUT_DIR -type f -name "*.pdf"); do 
    NAME="$(basename $f .pdf | tr '-' ' ')" LINK="${f#$PATTERN}" yq -i \
     '.files += [{"name": strenv(NAME), "link": strenv(LINK)}]' \
     "$OUTPUT_FILE"
done