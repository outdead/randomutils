#!/bin/sh
mkdir compressed

BASEDIR=$(dirname "$(readlink -f "$BASH_SOURCE")")

for i in *.jpg; do jpegoptim -d ./compressed -p "$i" -m85; done
for i in *.png; do pngquant --quality=90-100 --skip-if-larger "$i" --output "${BASEDIR}/compressed/$i"; done
