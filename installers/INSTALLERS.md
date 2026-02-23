# SAP HANA Express Installers

This directory should contain the SAP HANA Express Edition installer archives. These files are not included in the repository due to licensing restrictions.

## Required Files

| File | Size | Description |
|------|------|-------------|
| `hxe.tgz` | ~2 GB | SAP HANA Express server |
| `hxexsa.tgz` | ~15 GB | XS Advanced (optional - Web IDE, HANA Cockpit) |

## Download Instructions

1. Go to [SAP HANA Express Edition Download](https://www.sap.com/cmp/td/sap-hana-express-edition.html)
2. Register or log in with your SAP account (free registration)
3. Download the **Download Manager** 
4. Run the Download Manager (requires Java)
5. Select the packages to download:
   - `hxe.tgz` (Server only)
   - `hxexsa.tgz` (XS Advanced - optional)
6. Move the downloaded files to this directory

## Directory Structure After Download

```
installers/
├── INSTALLERS.md          # This file
├── hxe.tgz                # SAP HANA Express server
└── hxexsa.tgz             # XS Advanced (optional)
```
