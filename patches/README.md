# Folder: patches

This directory is used to store **Oracle software patches** downloaded using the
`autoupgrade.jar` utility.

Patches are typically downloaded with the following command:

```bash
java -jar jar/autoupgrade.jar -config etc/download_patch.cfg -mode download
````

This includes:

* Patch ZIP files (e.g. `.zip` files downloaded from MOS)
* Patch metadata and manifests (if applicable)

📁 **Notes**:

* Only official Oracle patch ZIP files should be stored here.
* Patch files should be organized and clearly named.
* You can include version or patch numbers in the filename for clarity.

❌ **Excluded**:

* JAR tools (e.g. `autoupgrade.jar`) — these go in the `jar/` folder
* Extracted or temporary files
* Log files or user-generated scripts

Please ensure patch files are current and avoid storing unnecessary archives.
