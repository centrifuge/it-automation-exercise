#!/usr/bin/env bash
# Snapshot the live response headers of every Northwind hostname.
#
# Usage: scripts/capture-headers.sh [before|after]
#
# Read-only against the network. Writes one snapshot file under
# header-snapshots/. Run it before a header change and again after the apply,
# then diff the two files.
#
# Deliberately no `set -e`: some hosts legitimately do not send some of the
# headers below, which makes grep exit 1, and aborting a snapshot over an
# absent header would defeat the point of taking one. pipefail stays on so a
# real curl failure shows up rather than an empty line.
set -uo pipefail

LABEL=${1:-before}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="header-snapshots"
OUTPUT_FILE="${OUTPUT_DIR}/headers-${LABEL}-${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

HOSTS=(
    "https://northwind.test"
    "https://www.northwind.test"
    "https://app.northwind.test"
    "https://docs.northwind.test"
    "dash.northwind.test"
    "https://partners.northwind.test"
    "https://legacy.northwind.test"
    "https://nightly.app.preview.northwind.test"
    "https://preview.app.preview.northwind.test"
)

HEADERS_OF_INTEREST=(
    "content-security-policy"
    "strict-transport-security"
    "x-content-type-options"
    "referrer-policy"
)

{
    echo "=============================================="
    echo "Northwind header snapshot: ${LABEL} ${TIMESTAMP}"
    echo "=============================================="
    echo

    for host in "${HOSTS[@]}"; do
        echo "--- ${host} ---"
        response=$(curl -sSI --max-time 10 "$host" 2>&1)
        for header in "${HEADERS_OF_INTEREST[@]}"; do
            echo "$response" | grep -i "^${header}:" || echo "${header}: (absent)"
        done
        echo
    done
} >"$OUTPUT_FILE"

echo "wrote ${OUTPUT_FILE}"
