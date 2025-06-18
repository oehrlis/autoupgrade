#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: run_autoupgrade.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.06.17
# Version....: v0.2.0
# Purpose....: Wrapper script to run Oracle AutoUpgrade with optional envsubst
# Notes......: - Automatically resolves env variables if -config is specified
#              - Passes all CLI parameters to AutoUpgrade
#              - Checks for Java and autoupgrade.jar
# Reference..: https://github.com/oehrlis
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.06.17 oehrli - added dynamic param handling and conditional config parsing
# ------------------------------------------------------------------------------

# - Default Values -------------------------------------------------------------
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
SCRIPT_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_BASE=$(dirname "${SCRIPT_BIN_DIR}")
AUTOUPGRADE_BASE="${SCRIPT_BASE}"
SCRIPT_JAR_DIR="${SCRIPT_BASE}/jar"
JAR_FILE="${SCRIPT_JAR_DIR}/autoupgrade.jar"
TMP_CFG=""
# - EOF Default Values ---------------------------------------------------------

# - Functions ------------------------------------------------------------------

# Print error and exit
function error_exit {
    echo "ERROR: $1" >&2
    exit 1
}

# Resolve environment variables in config file
function resolve_config {
    local config_path="$1"
    TMP_CFG="/tmp/autoupgrade_resolved_$$.cfg"
    echo "Resolving environment variables in config: ${config_path}"
    envsubst < "${config_path}" > "${TMP_CFG}"
}

# - EOF Functions --------------------------------------------------------------

# - Parse Parameters -----------------------------------------------------------
ARGS=()
CONFIG_FILE=""
RESOLVE_CONFIG=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -config)
            CONFIG_FILE="$2"
            RESOLVE_CONFIG=true
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
# - EOF Parse Parameters -------------------------------------------------------

# - Main Script Logic ----------------------------------------------------------

# Check Java availability
command -v java >/dev/null 2>&1 || error_exit "Java not found in PATH."

# Check for autoupgrade.jar
[[ -f "${JAR_FILE}" ]] || error_exit "AutoUpgrade JAR not found at ${JAR_FILE}"

# Handle config substitution if needed
if [[ "${RESOLVE_CONFIG}" = true ]]; then
    [[ -f "${CONFIG_FILE}" ]] || error_exit "Config file not found: ${CONFIG_FILE}"
    resolve_config "${CONFIG_FILE}"
    echo "Running AutoUpgrade with resolved config..."
    java -jar "${JAR_FILE}" -config "${TMP_CFG}" "${ARGS[@]}"
    rm -f "${TMP_CFG}"
else
    echo "Running AutoUpgrade with original parameters..."
    java -jar "${JAR_FILE}" "${ARGS[@]}"
fi

# - EOF ------------------------------------------------------------------------
