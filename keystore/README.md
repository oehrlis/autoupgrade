# Folder: keystore

This directory is used to store the **Oracle AutoUpgrade keystore**, which securely
holds the My Oracle Support (MOS) credentials required to download patches.

The keystore is referenced via the `global.keystore` property in your AutoUpgrade
configuration file (`download_patch.cfg`), e.g.:

```properties
global.keystore=/Users/stefan.oehrli/Development/github/oehrlis/autoupgrade/keystore
````

## 🔐 Creating the Keystore

You can create or update the keystore using the following command:

```bash
java -jar jar/autoupgrade.jar -config etc/download_patch.cfg -patch -load_password
```

This starts the AutoUpgrade keystore CLI. Below is a typical session:

```text
Processing config file ...

Starting AutoUpgrade Patching Password Loader - Type help for available options
Creating new AutoUpgrade Patching keystore - Password required
Enter password:
Enter password again:
AutoUpgrade Patching keystore was successfully created

MOS> add -user <mos user e-mail>
Enter your secret/Password:
Re-enter your secret/Password:
MOS> save
Convert the AutoUpgrade Patching keystore to auto-login [YES|NO] ? yes
MOS> exit

AutoUpgrade Patching Password Loader finished - Exiting AutoUpgrade Patching
```

## 🚫 Git Exclusion

The keystore wallet contains **sensitive credentials** and must not be committed to
version control.

Use the following `.gitignore` entry to exclude the wallet while keeping this README:

```gitignore
# Ignore wallet contents but keep README
keystore/*
!keystore/README.md
```

## 🔄 Recreating the Keystore

If the keystore is deleted or lost, simply rerun:

```bash
java -jar jar/autoupgrade.jar -config etc/download_patch.cfg -patch -load_password
```

and follow the prompts to set up the keystore and store your credentials.

📌 **Important**: Only store credentials for personal or automation use cases. Use
group management if multiple users require access.
