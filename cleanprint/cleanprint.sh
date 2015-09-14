#!/usr/bin/env bash
set -e

PRINTER=${2:-{{printer}}}
FILENAME=$(basename "$1")

function notify () {
    local TITLE="${1}"
    local TEXT="${2}"
    notify-send "${TITLE}" "${TEXT}" --icon=dialog-information
}

if [[ ! -f "$1" ]]; then
    notify "ERROR" "$1 is not a file."
    exit 42
fi

if ! file "$1" 2>&1 | grep -i "PDF document"; then
    notify "ERROR" "$1 is not a PDF file."
    exit 23
fi

TMPDIR=$(mktemp -d /tmp/CLEANPRINT.XXXXX)
trap "[[ -d \"${TMPDIR}\" ]] && rm -rf \"${TMPDIR}\"" SIGHUP SIGINT EXIT ERR
notify "INFO" "Converting ${FILENAME}"
gs -o "${TMPDIR}/${FILENAME}" -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "$1"
notify "INFO" "Printing ${FILENAME}"
lp -d "${PRINTER}" "${FILENAME}"
notify "INFO" "SUCCESS"

