#!/bin/bash

VERSION="0.1.0"
YEAR="2021"
AUTHOR="Pavel Korotkiy (outdead)"

FILE_NAME="$1"
FORMAT="$2"
OUTPUT_FILE_NAME="${FILE_NAME%.*}.${FORMAT}"

QUALITY=30

while [[ -n "$1" ]]; do
    case "$1" in
        version|v|--version|-v)
            echo "$0 version $VERSION"
            exit ;;
        help|h|--help|-h)
            echo "NAME:"
            echo "   ${0##*/} script allows you to covert video files to various formats"
            echo
            echo "USAGE:"
            echo "   $0 filename format -q quality"
            echo
            echo "VERSION:"
            echo "   $VERSION"
            echo
            echo "Description:"
            echo "   You must set filename and desired format."
            echo
            echo "COMMANDS:"
            echo "   help, h     Shows a list of commands or help for one command"
            echo "   version, v  Prints $0 version"
            echo
            echo "GLOBAL OPTIONS:"
            echo "   --help, -h     show help"
            echo "   --version, -v  print the version"
            echo
            echo "OPTIONS:"
            echo "   --quality, -q  sets video quality (default 5)"
            echo
            echo "COPYRIGHT:"
            echo "   Copyright (c) $YEAR $AUTHOR"
            exit;;
        --quality|-q) param="$2"
            QUALITY="$param"
            if [ -z "${QUALITY}" ]; then echo "quality is not set. Use $0 filename format -q quality" >&2; exit 1; fi

            if [ "$FILE_NAME" == "-q" ] || [ "$FILE_NAME" == "--quality" ] || [ "$FORMAT" == "-q" ] || [ "$FORMAT" == "--quality" ]; then
              echo "quality must be the last argument. Use $0 filename format -q quality" >&2
              exit 1
            fi
            shift ;;
        --) shift
            break ;;
    esac

    shift
done

if [ -z "${FILE_NAME}" ]; then echo "filename is not set. Use $0 filename format -q quality" >&2; exit 1; fi
if [ -z "${FORMAT}" ]; then echo "format is not set. Use $0 filename format -q quality" >&2; exit 1; fi

ffmpeg -i "${FILE_NAME}" -crf "${QUALITY}" "${OUTPUT_FILE_NAME}" && \
echo "    quality : ${QUALITY}" && \
echo " input file : ${FILE_NAME}" && \
echo "output file : ${OUTPUT_FILE_NAME}"
