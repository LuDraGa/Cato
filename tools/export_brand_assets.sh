#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRAND_DIR="$ROOT_DIR/assets/brand"
MASTER_SVG="$BRAND_DIR/brand_master.svg"
FOREGROUND_SVG="$BRAND_DIR/brand_foreground.svg"

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "rsvg-convert is required. Install librsvg, then rerun this script." >&2
  exit 1
fi

rsvg-convert "$MASTER_SVG" -w 1024 -h 1024 -o "$BRAND_DIR/master_logo.png"
rsvg-convert "$FOREGROUND_SVG" -w 1024 -h 1024 -o "$BRAND_DIR/foreground_icon.png"
rsvg-convert "$MASTER_SVG" -w 512 -h 512 -o "$BRAND_DIR/logo_center.png"
rsvg-convert "$MASTER_SVG" -w 64 -h 64 -o "$BRAND_DIR/favicon.png"
rsvg-convert "$MASTER_SVG" -w 1024 -h 500 -o "$BRAND_DIR/feature_graphic.png"
rsvg-convert "$MASTER_SVG" -w 1200 -h 630 -o "$BRAND_DIR/og_image.png"

cat <<'EOF'
Brand PNG exports complete.

Next steps:
  flutter pub run flutter_launcher_icons
  flutter pub run flutter_native_splash:create

For a production mark, replace assets/brand/brand_master.svg and
assets/brand/brand_foreground.svg, then rerun this script.
EOF

