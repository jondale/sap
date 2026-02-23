# SAP HANA Express on Proxmox

Automated deployment of SAP HANA Express Edition on Proxmox VE and RHEL with Terraform and Ansible.

## Overview

This project provisions a RHEL 9 VM on Proxmox and installs SAP HANA Express Edition with optional XS Advanced (Web IDE, HANA Cockpit).

## Prerequisites

- Proxmox VE cluster
- RHEL 9 cloud-init template (see `create_proxmox_template.sh`)
- RHEL subscription with access to SAP repositories
- SAP HANA Express installer files (see [installers/INSTALLERS.md](installers/INSTALLERS.md))
- OpenTofu/Terraform
- Ansible with `community.sap_install` collection

## Quick Start

1. **Create the VM template on Proxmox**
   ```bash
   # Run on Proxmox host
   ./create_proxmox_template.sh
   ```

2. **Download SAP HANA Express installers**

   Download from [SAP](https://www.sap.com/cmp/td/sap-hana-express-edition.html) and place in `installers/`:
   - `hxe.tgz` (required)
   - `hxexsa.tgz` (optional, for XSA/Web IDE)

3. **Configure Terraform**
   ```bash
   ./create_terraform_vars.sh
   ```

4. **Configure Ansible vault**
   ```bash
   ./create_ansible_vault.sh
   ```

5. **Provision the VM**
   ```bash
   ./run_terraform.sh
   ```

6. **Install SAP HANA**
   ```bash
   ./run_ansible.sh
   ```

7. **Verify installation**
   ```bash
   ./verify_install.sh
   ```

## VM Requirements

SAP HANA Express minimum requirements:
- 4 CPU cores
- 32 GB RAM
- 120 GB disk

## Web Services

After installation with XSA, the following services are available (replace `<hostname>` with your VM's FQDN):

| Service | URL | Description |
|---------|-----|-------------|
| HANA Cockpit | `https://<hostname>:51039` | Database administration |
| XSA Cockpit | `https://<hostname>:51031` | XSA administration |
| Web IDE | `https://<hostname>:53075` | Development environment |

Default login: `XSA_ADMIN` with the master password set during installation.


## Documentation

- [NOTES.md](NOTES.md) - Detailed technical documentation
- [installers/INSTALLERS.md](installers/INSTALLERS.md) - SAP HANA Express download instructions

## License

GPL-3.0
