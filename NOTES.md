# Infrastructure Overview

## Platform

### Proxmox VE
Proxmox provides the virtualization layer. VMs are created from cloud-init enabled templates, allowing automated provisioning via Terraform.

### RHEL 9 for SAP Solutions
SAP HANA officially supports SLES and RHEL, both of which provide SAP-specific repositories with required packages like `compat-sap-c++-13` (provides GLIBCXX_3.4.32 for HANA 2.00.088+). This project uses RHEL 9 via a free Red Hat Developer subscription. Since we're not using SLES, we must set `HDB_INSTALLER_ALLOW_NON_SUSE=1` during installation.

### VM Template
Built with RHEL Image Builder with auto-subscription enabled. The template is cloud-init ready and automatically registers with Red Hat on first boot.

---

## Terraform

Provisions the VM infrastructure on Proxmox.

### What it does

| Resource | Purpose |
|----------|---------|
| Clone template | Creates VM from RHEL 9 template |
| Set resources | 4 CPU, 32GB RAM, 120GB disk (SAP HANA Express minimums) |
| Configure network | Static IP via cloud-init |
| Set CPU type | `host` for CPU passthrough (performance) |

---

## Ansible

Configures the VM and installs SAP HANA Express.

### Play 1: System Preparation

| Task | Why |
|------|-----|
| Set SELinux to permissive | SAP HANA requires permissive or disabled SELinux |
| Clean up /etc/hosts | SAP roles require single FQDN entry per hostname |
| Enable SAP Solutions repo | Access to `compat-sap-c++-13` and SAP-tuned packages |
| Install compat-sap-c++-13 | Provides GLIBCXX_3.4.32 required by HANA 2.00.088+ |
| sap_general_preconfigure role | Kernel parameters, packages, ulimits, uuidd (SAP Notes compliance) |
| sap_hana_preconfigure role | HANA-specific tuning, THP disabled, NUMA settings |
| Configure firewall | Open HANA ports (39015, 8090, etc.) |
| Create /hana directories | HANA installation paths (/hana/shared, /hana/data, /hana/log) |
| Create swap | 32GB swap file (SAP recommendation for dev environments) |

### Play 2: HANA Installation

| Task | Why |
|------|-----|
| Check for existing install | Skip if already installed (idempotency) |
| Copy installer archives | Transfer hxe.tgz (and hxexsa.tgz if XSA) to remote |
| Extract archives | Prepare installer files |
| Run setup_hxe.sh | Execute SAP HANA Express installer in batch mode |
| Verify installation | Check HANA services are running |

---

## Scripts

| Script | Purpose | Run Location |
|--------|---------|--------------|
| `create_proxmox_template.sh` | Creates RHEL 9 cloud-init VM template | Proxmox cluster |
| `create_terraform_vars.sh` | Generates `terraform/terraform.tfvars` | Local |
| `create_ansible_vault.sh` | Generates `ansible/group_vars/all/vault.yml` | Local |
| `run_terraform.sh` | Provisions VM on Proxmox | Local |
| `run_ansible.sh` | Configures VM and installs SAP HANA | Local |

SAP HANA Express installers go in `installers/` directory (see [installers/INSTALLERS.md](installers/INSTALLERS.md)).

---

## References

- `Getting_Started_HANAexpress_Binary_Installer.pdf` - Included with SAP HANA Express download
- [SAP HANA Express Download](https://www.sap.com/products/technology-platform/hana/express-trial.html)
- [Red Hat Developer Subscription](https://developers.redhat.com/register) - Free RHEL subscription with SAP repos
- [community.sap_install Collection](https://github.com/sap-linuxlab/community.sap_install) - Ansible Galaxy collection for SAP
- [SAP HANA Academy YouTube](https://www.youtube.com/c/SAPHANAAcademy) - Video tutorials
