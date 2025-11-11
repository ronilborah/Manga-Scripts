#!/bin/bash
# Script to create a simple app icon

# Create a temporary directory for icon generation
temp_dir=$(mktemp -d)
cd "$temp_dir"

# Create a 512x512 PNG image with ImageMagick or sips
# If ImageMagick is not available, we'll create a simple colored icon

# Try to create icon with sips (built-in macOS tool)
cat > icon_template.svg << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <rect width="512" height="512" rx="115" fill="#4A90E2"/>
  <text x="256" y="320" font-family="Arial, sans-serif" font-size="200" font-weight="bold" fill="white" text-anchor="middle">M</text>
  <text x="256" y="420" font-family="Arial, sans-serif" font-size="60" fill="white" text-anchor="middle">Manga</text>
</svg>
EOF

# Create iconset directory
mkdir AppIcon.iconset

# Try to convert SVG to PNG and create different sizes
# This requires having tools installed, so we'll make it optional
if command -v convert &> /dev/null; then
    # ImageMagick is available
    for size in 16 32 128 256 512; do
        convert icon_template.svg -resize ${size}x${size} "AppIcon.iconset/icon_${size}x${size}.png"
        convert icon_template.svg -resize $((size*2))x$((size*2)) "AppIcon.iconset/icon_${size}x${size}@2x.png"
    done
elif command -v sips &> /dev/null; then
    # Use a simple colored rectangle approach with sips
    # Create base PNG
    python3 << 'PYEOF'
from PIL import Image, ImageDraw, ImageFont
import os

# Create a 1024x1024 image
img = Image.new('RGB', (1024, 1024), color='#4A90E2')
draw = ImageDraw.Draw(img)

# Try to add text
try:
    font_large = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 400)
    font_small = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 120)
except:
    font_large = ImageFont.load_default()
    font_small = ImageFont.load_default()

# Draw text
draw.text((512, 400), 'M', font=font_large, fill='white', anchor='mm')
draw.text((512, 720), 'Manga', font=font_small, fill='white', anchor='mm')

img.save('base_icon.png')
print("Icon created successfully")
PYEOF

    # Create different sizes
    for size in 16 32 128 256 512; do
        sips -z $size $size base_icon.png --out "AppIcon.iconset/icon_${size}x${size}.png" &> /dev/null
        sips -z $((size*2)) $((size*2)) base_icon.png --out "AppIcon.iconset/icon_${size}x${size}@2x.png" &> /dev/null
    done
fi

# Convert iconset to icns
if [ -d "AppIcon.iconset" ]; then
    iconutil -c icns AppIcon.iconset -o AppIcon.icns
    
    # Copy to the app
    cp AppIcon.icns "/Users/ronil/Desktop/Manga-Scripts/Manga Downloader.app/Contents/Resources/"
    echo "Icon created and copied to app"
else
    echo "Could not create icon - tools not available"
fi

# Clean up
cd ..
rm -rf "$temp_dir"
