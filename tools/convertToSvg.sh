#!/usr/bin/env bash
INPUT_DIR="img-test"
OUTPUT_DIR="static/images/dojos"

if [ ! -d "$INPUT_DIR" ]; then
    echo "Input directory '$INPUT_DIR' not found. Please create it and place your PNG files inside."
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo "Created output directory '$OUTPUT_DIR'."
fi

for png_file in "$INPUT_DIR"/*.png; do
    if [ ! -f "$png_file" ]; then
        echo "No PNG files found in '$INPUT_DIR'."
        break
    fi

    filename=$(basename "$png_file" .png)

    hex_color=$(convert "$png_file" -background none -flatten -format '%[hex:p{0,0}]' info:- | head -c -2)

    base64_image=$(base64 -w 0 "$png_file")

    cat > "$OUTPUT_DIR/$filename.svg" << EOF
<svg viewBox="0 0 2160 1080" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#$hex_color"/>
  <image href="data:image/png;base64,$base64_image" x="540" y="0" width="1080" height="1080" preserveAspectRatio="xMidYMid meet"/>
</svg>
EOF

    echo "Converted '$png_file' to '$OUTPUT_DIR/$filename.svg'."

done