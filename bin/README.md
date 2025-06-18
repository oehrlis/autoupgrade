# Folder: bin

This folder contains **utility scripts** used to manage Oracle AutoUpgrade-related
operations, such as downloading patches, updating the AutoUpgrade JAR, and exporting
documentation.

These scripts are intended to simplify execution, enforce structure, and support
cross-platform consistency.

## Included Scripts

### 🔧 `run_autoupgrade.sh`

Wrapper script to run `autoupgrade.jar` with enhanced features:

- Automatically sets `AUTOUPGRADE_BASE` based on its own location
- Supports both absolute and relative `-config` paths
- Resolves environment variables inside the config file using `envsubst`

**Example usage:**
```bash
./bin/run_autoupgrade.sh -config etc/download_patch.cfg -mode download
````

This script is the recommended way to run any AutoUpgrade task using `.cfg` files
located in the `etc/` folder.

### 📥 `update_autoupgrade.sh`

Downloads the latest `autoupgrade.jar` from Oracle and stores it in the `jar/` folder.
If a JAR already exists and the content has changed, it creates a backup using the
build version or timestamp.

**Example usage:**

```bash
./bin/update_autoupgrade.sh
```

This script ensures you're always working with the latest available AutoUpgrade tool.

### 📝 `generate_pdf.sh`

Generates PDF documentation from Markdown sources in the `doc/` folder using Pandoc.

**Note:** This script is included and ready, but only functional once documentation
sources are available.

**Example usage:**

```bash
./bin/generate_pdf.sh doc/template.md
```

PDF output is written to the `artefacts/` folder. Fonts used for styling are located
in the `fonts/` directory.

## Notes

* All scripts follow a standardized OraDBA script header format
* Scripts are compatible with macOS, Linux, and container-based environments
* `run_autoupgrade.sh` is the preferred entry point for all AutoUpgrade use cases
