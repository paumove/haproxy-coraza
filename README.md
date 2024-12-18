# WAF Configuration Guide with Coraza-spoa and HAProxy v2.4.22 on AlmaLinux (RHEL-based systems)

## About This Fork
This repository is a **fork** of the original [haproxy-coraza](https://github.com/thelogh/haproxy-coraza) project. The original guide and scripts were designed for Ubuntu Server 22.04 LTS. This fork adapts the installation process and configuration to work seamlessly on **AlmaLinux** (and other RHEL-based systems).  
If you're using Ubuntu, please refer to the [original repository](https://github.com/thelogh/haproxy-coraza) for installation instructions.

---

## Basic Version:
This example provides a basic configuration to familiarize users with the OWASP ModSecurity Core Rule Set (CRS) 4.0, Coraza, and HAProxy rules.

For step-by-step instructions on the installation of **Coraza-spoa** (based on Coraza WAF v3.0.1) tailored for AlmaLinux, follow the guide in this repository.  
Additionally, an automatic installation script **"[install-coraza_almalinux.sh](https://github.com/yourusername/haproxy-coraza-almalinux/blob/main/install-coraza_almalinux.sh)"** is included to simplify the process. This script is designed for clean AlmaLinux installations and is suitable for testing purposes.

---

## Advanced Version:
The advanced configuration supports real-world scenarios, such as:
- **Multiple domains:** Custom configurations tailored to specific domains.
- **Plugins:** Integration with specific plugins, for example, those optimized for WordPress sites.

This setup is based on the **OWASP ModSecurity Core Rule Set (CRS) 4.0** and provides enhanced flexibility for production use cases.

---

## Differences from the Original Project:
- Adapted for **AlmaLinux** and other **RHEL-based systems**.
- Uses `dnf` for package management instead of `apt`.
- Includes changes to paths, permissions, and systemd service management to align with RHEL-based conventions.
- Ensures compatibility with Go installations from the AlmaLinux repositories.

For further details, refer to the modified scripts and instructions in this repository.

---

## Original Project
The original project by [thelogh](https://github.com/thelogh) can be found here:  
[https://github.com/thelogh/haproxy-coraza](https://github.com/thelogh/haproxy-coraza)  
It includes installation scripts and configurations for Ubuntu Server 22.04 LTS.
