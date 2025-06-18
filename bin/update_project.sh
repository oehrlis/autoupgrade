#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: update_project.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.06.18
# Version....: v0.3.0
# Purpose....: In-place update of the AutoUpgrade project folder from a ZIP
# Notes......: Backup excludes patch ZIPs, tool logs and log files.
# Reference..: https://github.com/oehrlis
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.06.18 oehrli - refine backup exclusions for ZIPs and cfgtoollogs
# ------------------------------------------------------------------------------

# - Default Values -------------------------------------------------------------
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
SCRIPT_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT_BASE=$(dirname "${SCRIPT_BIN_DIR}")
TARGET_DIR="${SCRIPT_BASE}"
# - EOF Default Values ---------------------------------------------------------

# - Functions ------------------------------------------------------------------
function usage() {
    echo "Usage: ${SCRIPT_NAME} <autoupgrade_project_zip>"
    echo
    echo "Safely updates the AutoUpgrade project folder from a ZIP archive."
    echo "The backup excludes:"
    echo "  - patch ZIP files (patches/*.zip)"
    echo "  - cfgtoollogs folder (logs/cfgtoollogs/)"
    echo "  - *.log files in logs/"
    exit 1
}
# - EOF Functions --------------------------------------------------------------

# - Parse Parameters -----------------------------------------------------------
ZIP_FILE="$1"
if [[ -z "$ZIP_FILE" || ! -f "$ZIP_FILE" ]]; then
    echo "❌ Missing or invalid ZIP file."
    usage
fi
# - EOF Parse Parameters -------------------------------------------------------

# - Main Script Logic ----------------------------------------------------------
TMP_DIR=$(mktemp -d)
BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d%H%M%S)"

echo "🔄 Backing up existing project (excluding *.zip, *.log, cfgtoollogs)..."
rsync -a \
    --exclude='patches/*.zip' \
    --exclude='logs/cfgtoollogs/' \
    --exclude='logs/*.log' \
    "$TARGET_DIR/" "$BACKUP_DIR/"

echo "📦 Unpacking ZIP file to temp directory..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"
NEW_SOURCE_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "autoupgrade-*")

if [[ -z "$NEW_SOURCE_DIR" ]]; then
    echo "❌ Could not find unpacked project folder in ZIP."
    rm -rf "$TMP_DIR"
    exit 2
fi

echo "🔁 Syncing updated project files into $TARGET_DIR ..."
rsync -a \
    --exclude='patches/*.zip' \
    --exclude='logs/cfgtoollogs/' \
    --exclude='logs/*.log' \
    "$NEW_SOURCE_DIR"/ "$TARGET_DIR/"

echo "🧹 Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "✅ AutoUpgrade project updated successfully."
echo "💡 Backup stored at: $BACKUP_DIR"
# - EOF ------------------------------------------------------------------------
