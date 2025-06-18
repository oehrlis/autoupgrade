# Oracle AutoUpgrade Utilities

This repository provides a structured environment for working with Oracle's
**AutoUpgrade** tool across various use cases. It includes reusable scripts,
example configurations, and documentation to support practical AutoUpgrade
scenarios.

The goal is to streamline typical Oracle database lifecycle operations by
automating and documenting:

- Patching (including quarterly CPUs and RUs) in particular when done on a different system than the database server.
- Multi-platform patch download automation
- Migrations (e.g. Single Tenant to Multitenant)
- Pre-checks and upgrade readiness validations
- Secure keystore setup for patch access via My Oracle Support (MOS)

## 🧰 Features

- Script to download and update the latest `autoupgrade.jar`
- Preconfigured patch download automation (multi-platform)
- Secure keystore management for My Oracle Support credentials
- Example upgrade configuration files (e.g., for DB 19c → 23ai)
- Support for both standalone and containerized environments
- PDF-ready documentation structure with Pandoc export

## 🚀 Getting Started

### 1. Download the latest `autoupgrade.jar`

```bash
./bin/update_autoupgrade.sh
```

### 2. Configure MOS credentials (if downloading patches)

```bash
java -jar jar/autoupgrade.jar -config etc/download_patch.cfg -patch -load_password
```

### 3. Run your specific use case

- **Download patches**:

  ```bash
  java -jar jar/autoupgrade.jar -config etc/download_patch.cfg -mode download
  ```

- **Run pre-checks or upgrade**:
  See the sample upgrade config files under `etc/`.

## 📁 Folder Overview

| Folder       | Description                                                       |
| ------------ | ----------------------------------------------------------------- |
| `artefacts/` | Output files such as PDFs, reports, and exports                   |
| `bin/`       | Shell scripts for automation (e.g. upgrade, patching, PDF export) |
| `doc/`       | Markdown-based documentation and Pandoc templates                 |
| `etc/`       | Sample AutoUpgrade config files (patching, upgrades, settings)    |
| `fonts/`     | Custom fonts for PDF output                                       |
| `images/`    | Diagrams, logos, and reference images                             |
| `jar/`       | Location for `autoupgrade.jar` and versioned backups              |
| `keystore/`  | Secure MOS credential keystore (excluded via `.gitignore`)        |
| `logs/`      | AutoUpgrade-generated logs (patching, examiner, etc.)             |
| `patches/`   | Oracle patch ZIPs downloaded via AutoUpgrade                      |

## 🔐 Keystore (for Patch Download Only)

A keystore is needed **only** if you want AutoUpgrade to download patches
directly from My Oracle Support.

Create it using:

```bash
java -jar jar/autoupgrade.jar -config etc/download_patch.cfg -patch -load_password
```

The actual wallet is stored in `keystore/` and excluded from Git.
See [`keystore/README.md`](keystore/README.md) for details.

## 🔧 Example Use Cases

This repository supports a range of real-world AutoUpgrade use cases:

- Apply Critical Patch Updates (CPU) or Release Updates (RU)
- Download and manage platform-specific patch sets
- Convert single-tenant DBs to multitenant architecture (CDB/PDB)
- Pre-check and analyze upgrade readiness
- Automate `autoupgrade.jar` lifecycle and configuration management

## 📝 Documentation and PDF Export

Write documentation in Markdown and generate PDFs using:

```bash
./bin/generate_pdf.sh doc/template.md
```

Fonts are stored under `fonts/`, output is written to `artefacts/`.

## 📜 License

Apache License 2.0 — See [LICENSE](LICENSE)

## 👤 Maintainer

Stefan Oehrli • [github.com/oehrlis](https://github.com/oehrlis)
