#!/usr/bin/env bash

VERSION="0.1.0"
YEAR="2017"
AUTHOR="Pavel Korotkiy (outdead)"

# Usage: ./shortcut.sh [name] [path]

(
	echo "[Desktop Entry]";
	echo "Name=$1";
	echo "Comment=";
	echo "GenericName=";
	echo "Keywords=";
	echo "Exec=$2";
	echo "Terminal=false";
	echo "Type=Application";
	echo "Icon=$1";
	echo "Path=";
	echo "Categories=";
	echo "NoDisplay=false";
) > "/usr/share/applications/$1.desktop"

DESKTOP_FOLDER="/home/$USER/Desktop"
[ -d "${DESKTOP_FOLDER}" ] || DESKTOP_FOLDER="/home/$USER/Рабочий стол"

kate "/usr/share/applications/$1.desktop" && cp "/usr/share/applications/$1.desktop" "${DESKTOP_FOLDER}/$1.desktop"
