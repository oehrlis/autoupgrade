#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: update_project.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.06.17
# Version....: v0.1.0
# Purpose....: Safely update the AutoUpgrade project folder using a provided ZIP
# Notes......: Preserves folders like etc, keystore, jar, patches, and logs
# Reference..: https://github.com/oehrlis
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.06.17 oehrli - initial version
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
    echo "This script updates the AutoUpgrade project folder from a GitHub ZIP"
    echo "while preserving etc/, keystore/, patches/, jar/, and logs/ folders."
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

echo "🔄 Backing up existing project (excluding patches, logs, jar)..."
rsync -a --exclude=patches/ --exclude=logs/ --exclude=jar/ "$TARGET_DIR/" "$BACKUP_DIR/"

echo "📦 Unpacking ZIP file..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"
NEW_SOURCE_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "autoupgrade-*")

if [[ -z "$NEW_SOURCE_DIR" ]]; then
    echo "❌ Could not find unpacked project folder in ZIP."
    exit 2
fi

echo "🧩 Syncing preserved folders (etc, keystore, patches, jar, logs)..."
for dir in etc keystore patches jar logs; do
    if [[ -d "$TARGET_DIR/$dir" ]]; then
        rsync -a "$TARGET_DIR/$dir/" "$NEW_SOURCE_DIR/$dir/"
    fi
done

echo "🚚 Updating project folder..."
OLD_DIR="${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)"
mv "$TARGET_DIR" "$OLD_DIR"
mv "$NEW_SOURCE_DIR" "$TARGET_DIR"

echo "🧹 Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "✅ Project updated successfully."
echo "💡 Backup stored in: $BACKUP_DIR"
echo "💡 Previous version moved to: $OLD_DIR"
# - EOF ------------------------------------------------------------------------
