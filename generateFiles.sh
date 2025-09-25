#!/usr/bin/env bash

# --- Configuration ---
INPUT_DIR="${1:-"./img"}"
OUTPUT_DIR="${2:-"."}"

LC_TIME="nl_NL.utf8"

# --- Setup ---
CONTENT_PATH="$OUTPUT_DIR/content/edities"
IMAGES_PATH="$OUTPUT_DIR/static/images/dojos"

if ! command -v magick &> /dev/null; then
    echo "Error: 'magick' (ImageMagick) is required but not found." >&2
    exit 1
fi

# Create necessary directories
echo "Creating output directories..."
mkdir -p "$CONTENT_PATH" "$IMAGES_PATH"

echo "Processing files from $INPUT_DIR..."

# --- Main Loop ---
for png_file in "$INPUT_DIR"/*.png; do
    if [[ ! -f "$png_file" ]]; then
        echo "No .png files found in $INPUT_DIR. Exiting loop."
        break
    fi

    date=$(basename "$png_file" .png)

    date_text=($(date -d $date +"%-d %B"))
    date_text="${date_text[@]^}"
    date_post=$(date -d $date +"%Y-%m-%d")
    image_path="/images/dojos/$date.svg"

    output_md_file="$CONTENT_PATH/$date.md"
    output_svg_file="$IMAGES_PATH/$date.svg"

    echo "Processing $date..."
    if [[ -f "$output_md_file" ]]; then
        echo "   Warning: Markdown file '$date.md' already exists. Skipping file creation."
    else
        cat > $output_md_file << EOF
---
title: "CoderDojo Helmond - $date_text"
date: "$date_post"
image: "$image_path"
description: "Deze Dojo vindt plaats bij JUUDS Foederer in Helmond."
tag: "Edities"
---
EOF
        echo "   Created $date.md"
    fi

    if [[ -f "$output_svg_file" ]]; then
        echo "   Warning: SVG image file '$date.svg' already exists. Skipping image creation."
    else
        hex_color="#$(magick "$png_file" -background none -flatten -format '%[hex:p{0,0}]' info:- | head -c -2)"

        if [[ -z "$hex_color" ]]; then
             echo "   Error: Could not extract hex color for $date. Skipping SVG creation." >&2
             continue
        fi

        base64_image=$(base64 -w 0 "$png_file")

        cat > $output_svg_file << EOF
<svg viewBox="0 0 2160 1080" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="$hex_color"/>
  <image href="data:image/png;base64,$base64_image" x="540" y="0" width="1080" height="1080" preserveAspectRatio="xMidYMid meet"/>
</svg>
EOF

        echo "   Created $date.svg"
    fi
done