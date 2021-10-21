#!/bin/bash

VERSION="0.1.0"
YEAR="2021"
AUTHOR="Pavel Korotkiy (outdead)"

FILE_NAME="$1"
OUTPUT_FILE_NAME="${FILE_NAME%.*}.java"

if [ -z "${FILE_NAME}" ]; then echo "filename is not set. Use $0 filename" >&2; exit 1; fi

procyon "${FILE_NAME}" > "${OUTPUT_FILE_NAME}"
