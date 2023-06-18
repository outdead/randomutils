#!/usr/bin/env bash

VERSION="0.1.0"
YEAR="2017"
AUTHOR="Pavel Korotkiy (outdead)"

# Usage: ./shortcut.sh [name] [path]

savefile() {
  sudo bash -c "cat <<EOF > /usr/share/applications/$1.desktop
[Desktop Entry]
Name=$1
Comment=
GenericName=
Keywords=
Exec=$2
Terminal=false
Type=Application
Icon=$1
Path=
Categories=
NoDisplay=false
EOF"
}

savefile "$1" "$2"

DESKTOP_FOLDER="/home/$USER/Desktop"
[ -d "${DESKTOP_FOLDER}" ] || DESKTOP_FOLDER="/home/$USER/Рабочий стол"

kate "/usr/share/applications/$1.desktop" && cp "/usr/share/applications/$1.desktop" "${DESKTOP_FOLDER}/$1.desktop"
