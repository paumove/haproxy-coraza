#!/bin/bash
# Coraza-spoa installer for AlmaLinux
#AUTOMATIC INSTALLATION SCRIPT WITH BASIC CORAZA-SPOA CONFIGURATION FOR HAPROXY ON ALMALINUX (RHEL BASED)
#https://github.com/thelogh/haproxy-coraza
#V.1.0.0

# Disable unwanted services
systemctl stop packagekit

# Update the system
dnf update -y

# Install development tools and dependencies
dnf groupinstall "Development Tools" -y
dnf install gcc make pkgconf-pkg-config git wget -y

# Install Go
dnf install golang -y

# Clone Coraza-spoa repository
git clone https://github.com/corazawaf/coraza-spoa.git
cd ./coraza-spoa

# Compile Coraza-spoa
# Modify Go version in go.mod if necessary
go build

# Create user and group for Coraza
groupadd --system coraza-spoa
useradd --system --home-dir /nonexistent --shell /sbin/nologin --gid coraza-spoa coraza-spoa

# Create configuration and log directories
mkdir -p /etc/coraza-spoa
mkdir -p /var/log/coraza-spoa /var/log/coraza-spoa/audit

# Create empty log files
touch /var/log/coraza-spoa/server.log /var/log/coraza-spoa/error.log \
      /var/log/coraza-spoa/audit.log /var/log/coraza-spoa/debug.log

# Copy compiled binary
cp -a ./coraza-spoa /usr/bin/coraza-spoa
chmod 755 /usr/bin/coraza-spoa

# Generate configuration file
cat << EOF > /etc/coraza-spoa/config.yaml
bind: 127.0.0.1:9000
default_application: haproxy_waf
applications:
  haproxy_waf:
    directives: |
      Include /etc/coraza-spoa/coraza.conf
      Include /etc/coraza-spoa/crs-setup.conf
      Include /etc/coraza-spoa/plugins/*-config.conf
      Include /etc/coraza-spoa/plugins/*-before.conf
      Include /etc/coraza-spoa/rules/*.conf
      Include /etc/coraza-spoa/plugins/*-after.conf
    no_response_check: true
    transaction_ttl_ms: 60000
    transaction_active_limit: 100000
    log_level: info
    log_file: /var/log/coraza-spoa/coraza-agent.log
EOF

# Download recommended Coraza configuration
wget https://raw.githubusercontent.com/corazawaf/coraza/main/coraza.conf-recommended -O /etc/coraza-spoa/coraza.conf

# Enable rules
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/coraza-spoa/coraza.conf

# Install OWASP CRS rules
mkdir -p ./coraza-crs
cd ./coraza-crs
git clone https://github.com/coreruleset/coreruleset
cp ./coreruleset/crs-setup.conf.example /etc/coraza-spoa/crs-setup.conf
cp -R ./coreruleset/rules /etc/coraza-spoa
cp -R ./coreruleset/plugins /etc/coraza-spoa
cd ..

# Set permissions
chown -R coraza-spoa:coraza-spoa /etc/coraza-spoa/
chmod -R 600 /etc/coraza-spoa/
chmod 700 /etc/coraza-spoa
chmod 700 /etc/coraza-spoa/rules
chmod 700 /etc/coraza-spoa/plugins

# Install and configure HAProxy
dnf install haproxy -y

# Copy example HAProxy configuration files
cd ..
cp -a ./basic/etc/haproxy/coraza.cfg /etc/haproxy/coraza.cfg
sed -i 's/app=str(sample_app) id=unique-id src-ip=src/app=str(haproxy_waf) id=unique-id src-ip=src/' /etc/haproxy/coraza.cfg
sed -i 's/app=str(sample_app) id=unique-id version=res.ver/app=str(haproxy_waf) id=unique-id version=res.ver/' /etc/haproxy/coraza.cfg
sed -i 's|event on-http-response|event on-http-response\n|' /etc/haproxy/coraza.cfg

# Backup original HAProxy configuration
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_orig
cp -a ./basic/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
sed -i -e '$a\' /etc/haproxy/haproxy.cfg

# Configure permissions for HAProxy
chown haproxy /etc/haproxy/coraza.cfg
chmod 600 /etc/haproxy/coraza.cfg

# Setup systemd service
cp -a ./coraza-spoa/contrib/coraza-spoa.service /etc/systemd/system/coraza-spoa.service
systemctl daemon-reload
#systemctl enable coraza-spoa.service

# Start services
systemctl stop haproxy
systemctl start coraza-spoa
systemctl start haproxy
