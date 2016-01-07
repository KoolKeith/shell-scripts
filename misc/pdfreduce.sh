#!/bin/bash
# Finds all pdf files recursivly in a given director and creates a low quality pdf file.

if [ "$1" = "" ]; then
  echo "You need to give me a folder..."
  exit 1
fi

RENDER_IN="/tmp" #useful on a ssd if /tmp is a tmpfs :)
EXTENSION="pdf"
ONLY_IF_LARGER_THEN=5000000 # In bytes; only try a low quality pdf for files larger than this limit.

if [ -d "$1" ]; then
  echo -en "\nStarting to work for directory \"${1}\"\n"
  find "${1}" -iname "*.${EXTENSION}" -print0 | while read -d '' -r file; do
    filesize_original=$(stat --printf="%s" "${file}")

    # Do not work with _low files
    echo "$file" | grep "_low.pdf"
    if [ $? = 0 ]; then
      echo -en "\n\nSkipping this file as it is the low quality variant."
      continue
    fi

    if [ -f "${path}/${filename_low_quality}" ]; then
      echo "A low quality variant for \"${filename}\" already exists, skipping."
      continue
    fi

    # We do only want to create low quality pdfs when the file size is larger or equal the the
    if [ ! ${filesize_original} -gt ${ONLY_IF_LARGER_THEN} ]; then
      continue
    fi

    path=$(dirname "${file}")
    filename=$(basename "${file}")
    filename_wo_ext=$(basename "${filename}" .${EXTENSION})
    filename_low_quality="${filename_wo_ext}_low.${EXTENSION}"

    echo -en "\n\nCurrent directory: \"${path}\"\n"
    echo -en "Current file: \"${filename}\"\n"
    echo -en "Original file size: $filesize_original bytes.\n"

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
    -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${RENDER_IN}/${filename_low_quality}" "${file}"
    if [ $? -gt 0 ]; then
      echo -en "Something went wrong creating the low quality file. Please check \"${RENDER_IN}/${filename_low_quality}\".\n"
    else
      filesize_low=$(stat --printf="%s" "${RENDER_IN}/${filename_low_quality}")
      echo "Low file size:      $filesize_low bytes"

      if [ $filesize_low -lt $filesize_original ]; then
        echo "Low variant SMALLER than original, moving it to the original file."
        echo "Low quality pendant named \"${filename_wo_ext}_low.${EXTENSION}\"."
        mv "${RENDER_IN}/${filename_low_quality}" "${path}/${filename_low_quality}"
      else
        echo "Low variant LARGER than original, removing it."
        rm "${RENDER_IN}/${filename_low_quality}"
      fi
    fi

    filesize_original=""
    filename=""
    filename_wo_ext=""
    filename_low_quality=""
    path=""
  done
fi
