# Folder: etc

This directory stores **AutoUpgrade configuration files** for different use cases,
such as patch downloads, upgrade execution, or database migrations.

Each `.cfg` file defines a specific scenario and contains settings for log paths,
keystore location, patch platforms, target homes, and more.

## 💼 Use Cases

| Config File          | Description                                                       |
|----------------------|-------------------------------------------------------------------|
| `download_patch.cfg` | Downloads Oracle 19c patches (RU, OJVM, OPatch, DPBP) for         |
|                      | Linux x86_64 and ARM platforms using the AutoUpgrade patch mode.  |

> Additional config files can be added for other use cases such as upgrades, 
> readiness checks, or conversions from non-CDB to PDB.

## 🧬 Environment Variables in Configs

To improve portability across systems, configuration files may contain
environment variables such as `$AUTOUPGRADE_BASE`, for example:

```properties
global.global_log_dir=$AUTOUPGRADE_BASE/logs
global.keystore=$AUTOUPGRADE_BASE/keystore
patch1.folder=$AUTOUPGRADE_BASE/patches
````

This allows all project-related files to be stored under a standard base directory,
e.g.:

```bash
/u00/app/oracle/autoupgrade/
```

**Note:** Oracle AutoUpgrade does **not** resolve these variables automatically.
You must preprocess the configuration before using it.

## 🛠 How to Resolve Environment Variables

### ✅ Option 1: Manually edit the config

Replace `$AUTOUPGRADE_BASE` with the full absolute path before using:

```properties
global.global_log_dir=/u00/app/oracle/autoupgrade/logs
```

### ✅ Option 2: Use `envsubst` to resolve variables

```bash
export AUTOUPGRADE_BASE=/u00/app/oracle/autoupgrade
envsubst < etc/download_patch.cfg > /tmp/resolved.cfg
java -jar jar/autoupgrade.jar -config /tmp/resolved.cfg -mode download
```

### ✅ Option 3: Use `run_autoupgrade.sh` (recommended)

The provided wrapper script automatically:

* Sets `AUTOUPGRADE_BASE` based on its own path
* Resolves any variables in the config via `envsubst`
* Supports both absolute and relative config paths

📦 Example:

```bash
./bin/run_autoupgrade.sh -config etc/download_patch.cfg -mode download
```

There is no need to export `AUTOUPGRADE_BASE` manually — the script does this for you
based on its location (e.g. `/u00/app/oracle/autoupgrade/bin/run_autoupgrade.sh`).

## 📁 Summary

* Store one `.cfg` file per AutoUpgrade use case in this folder.
* Use environment variables like `$AUTOUPGRADE_BASE` for portability.
* Let `run_autoupgrade.sh` handle resolution automatically for consistent usage.

See also `README.md` files in `jar/`, `patches/`, and `keystore/` for more details
on their respective components.
