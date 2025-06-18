# Folder: artefacts

This directory contains **both generated and manually maintained artefacts** of the project, including:

- **PDF documents** generated automatically from Markdown files using *Pandoc*
- **Excel files**, such as effort estimations, which may be edited and maintained manually
- **Presentations (PPTX)** or other Office documents edited using Microsoft Office or LibreOffice

## PDF Generation with Pandoc

PDF documents are generated from Markdown sources located in the `doc/` folder. A Docker container with Pandoc is used to ensure all dependencies are available in a clean environment.

Markdown documents can be written as a **single file** or split into **multiple parts** to improve structure and maintainability.
For example, `template.md` may be broken into:

- `template-part1.md`
- `template-part2.md`
- `template-part3-appendix.md`

All parts must follow the naming pattern `template*.md`. The build process merges them in order based on filename sorting.

Each document also requires a dedicated metadata file (e.g., `template.yml`) stored in the same folder.

### Example: PDF Generation

There are three ways to generate a PDF from the Markdown and metadata files:

1. **Using a local Pandoc and LaTeX installation**
2. **Using the Pandoc Docker container**
3. **Using the provided wrapper script `generate_pdf.sh`**, which internally uses the Docker image `oehrlis/pandoc`

#### Option 1: Local Pandoc + LaTeX (XeLaTeX required)

```bash
DOC_NAME=template
pandoc --metadata-file=doc/${DOC_NAME}.yml \
  --listings --pdf-engine=xelatex \
  --resource-path=images --filter pandoc-latex-environment \
  --output=artefacts/${DOC_NAME}.pdf doc/${DOC_NAME}*.md
```

#### Option 2: Pandoc via Docker (manual)

```bash
DOC_NAME=template
docker run --rm -v "$PWD":/workdir:z oehrlis/pandoc \
  --metadata-file=doc/${DOC_NAME}.yml \
  --listings --pdf-engine=xelatex \
  --resource-path=images --filter pandoc-latex-environment \
  --output=artefacts/${DOC_NAME}.pdf doc/${DOC_NAME}*.md
```

#### Option 3: Using `bin/generate_pdf.sh` (recommended)

```bash
./bin/generate_pdf.sh template
```

> ✅ This script wraps the Docker command and ensures consistent output using the `oehrlis/pandoc` container image.

### Notes

- The required **fonts** for rendering (e.g., for xelatex) are located in the `fonts/` directory.
- The generated PDF is saved into the `artefacts/` folder, which serves as the target location for all result files.
- Not all files in this folder are read-only — Excel or PPTX documents can be modified using standard Office tools.

> Please do not manually overwrite the PDF files — edits should be made in the corresponding Markdown source files under `doc/`.
