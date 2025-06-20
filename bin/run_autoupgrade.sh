#!/bin/bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: run_autoupgrade.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.06.17
# Version....: v0.4.0
# Purpose....: Wrapper script to run Oracle AutoUpgrade with optional envsubst
# Notes......: - Resolves -config path (absolute, relative to CWD or base)
#              - Automatically expands env variables if -config is given
#              - Sets AUTOUPGRADE_BASE based on script location
# Reference..: https://github.com/oehrlis
# License....: Apache License Version 2.0
# ------------------------------------------------------------------------------
# Modified...:
# 2025.06.17 oehrli - added AUTOUPGRADE_BASE env variable
# ------------------------------------------------------------------------------

# - Default Values -------------------------------------------------------------
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
SCRIPT_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_BASE=$(dirname "${SCRIPT_BIN_DIR}")
export AUTOUPGRADE_BASE="${SCRIPT_BASE}"                    # Set project base
SCRIPT_JAR_DIR="${AUTOUPGRADE_BASE}/jar"
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

# Resolve the config path from absolute or relative reference
function resolve_config_path {
    local input_path="$1"

    # Absolute path? Return it if it exists
    if [[ "${input_path}" = /* ]]; then
        [[ -f "${input_path}" ]] && echo "${input_path}" && return
    fi

    # Relative to current working directory?
    if [[ -f "${PWD}/${input_path}" ]]; then
        echo "${PWD}/${input_path}" && return
    fi

    # Relative to AUTOUPGRADE_BASE/etc?
    if [[ -f "${AUTOUPGRADE_BASE}/etc/${input_path}" ]]; then
        echo "${AUTOUPGRADE_BASE}/etc/${input_path}" && return
    fi

    # Or finally just look in AUTOUPGRADE_BASE/etc
    if [[ -f "${AUTOUPGRADE_BASE}/etc/$(basename ${input_path})" ]]; then
        echo "${AUTOUPGRADE_BASE}/etc/$(basename ${input_path})" && return
    fi

    # If not found
    error_exit "Configuration file not found: ${input_path}"
}
# - EOF Functions --------------------------------------------------------------

# - Parse Parameters -----------------------------------------------------------
ARGS=()
CONFIG_FILE=""
RESOLVE_CONFIG=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -config)
            RAW_CONFIG_PATH="$2"
            CONFIG_FILE="$(resolve_config_path "${RAW_CONFIG_PATH}")"
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
if ! command -v java >/dev/null 2>&1; then
    echo "❌ Java is not available or not in PATH. Aborting."
    exit 1
fi

# - Java Version Check ---------------------------------------------------------
JAVA_VERSION_FULL=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
JAVA_MAJOR=$(echo "$JAVA_VERSION_FULL" | cut -d. -f1)

if [[ "$JAVA_MAJOR" == "1" ]]; then
    JAVA_MAJOR=$(echo "$JAVA_VERSION_FULL" | cut -d. -f2)  # for Java 1.8
fi

if [[ "$JAVA_MAJOR" -ne 8 && "$JAVA_MAJOR" -ne 11 ]]; then
    echo "❌ Unsupported Java Runtime Environment: $JAVA_VERSION_FULL"
    echo "   AutoUpgrade must run with Java 8 or 11."
    exit 1
fi
# - EOF Java Version Check -----------------------------------------------------

# Check for autoupgrade.jar
[[ -f "${JAR_FILE}" ]] || error_exit "AutoUpgrade JAR not found at ${JAR_FILE}"

# Handle config substitution if needed
if [[ "${RESOLVE_CONFIG}" = true ]]; then
    resolve_config "${CONFIG_FILE}"
    echo "Running AutoUpgrade with resolved config..."
    echo "Using resolved config: ${TMP_CFG}"
    [[ -f "${TMP_CFG}" ]] || error_exit "Resolved config file not found: ${TMP_CFG}"
    # Run AutoUpgrade with resolved config
    java -jar "${JAR_FILE}" -config "${TMP_CFG}" "${ARGS[@]}"
    rm -f "${TMP_CFG}"
else
    echo "Running AutoUpgrade with original parameters..."
    java -jar "${JAR_FILE}" "${ARGS[@]}"
fi

# - EOF ------------------------------------------------------------------------