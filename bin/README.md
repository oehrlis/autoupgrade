# Folder: bin

This folder contains **utility scripts** used for managing the AutoUpgrade project, including updating the Oracle `autoupgrade.jar`, generating documentation, and performing safe in-place updates of the project itself.

## Included Scripts

### `run_autoupgrade.sh`

Wrapper script to run the Oracle `autoupgrade.jar` with enhanced behavior:

- Resolves relative paths to the config file
- Automatically substitutes environment variables (e.g. `$AUTOUPGRADE_BASE`) in config files
- Ensures a supported Java version (8 or 11) is used

**Usage:**

```bash
./bin/run_autoupgrade.sh -config etc/download_patch.cfg -mode download
```

### `update_autoupgrade.sh`

Downloads the latest version of Oracle's `autoupgrade.jar` into the `jar/` folder and creates a backup of the previous version based on the current build number or timestamp.

**Usage:**

```bash
./bin/update_autoupgrade.sh
```

### `update_project.sh`

Safely updates the entire project from a GitHub ZIP archive. It unpacks the ZIP into a temporary folder, merges it into the current project structure, and preserves the following folders:

- `etc/`
- `keystore/`
- `jar/`
- `patches/`
- `logs/`

It also creates a lightweight backup of the current project (excluding `patches/*.zip`, `logs/*.log`, and `logs/cfgtoollogs/`).

**Usage:**

```bash
./bin/update_project.sh /path/to/autoupgrade-main.zip
````

**To download the latest project ZIP from GitHub:**

```bash
curl -L -o autoupgrade-main.zip \
  https://github.com/oehrlis/autoupgrade/archive/refs/heads/main.zip
```

This command downloads the current `main` branch as a ZIP archive for use with `update_project.sh`. Useful in offline scenarios where the file must be downloaded externally and transferred to the target system.

### `generate_pdf.sh`

(Planned) Script to convert markdown-based documentation from the `doc/` folder into PDF using Pandoc and custom fonts. Ready to use once documentation content is available.

**Usage:**

```bash
./bin/generate_pdf.sh
```

## Notes

- `run_autoupgrade.sh` and `update_project.sh` will automatically determine the project root and resolve paths consistently.
- `update_project.sh` is ideal for offline environments or air-gapped servers where the project ZIP is downloaded externally.
