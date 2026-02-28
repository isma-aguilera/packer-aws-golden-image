#!/usr/bin/env bash
# 03_hardening.sh
# Configuración de seguridad del SO: sysctl, servicios, firewall y línea base.
set -euo pipefail

echo "==> [03] Security hardening"

# sysctl: parámetros de red y kernel
cat > /etc/sysctl.d/99-hardening.conf << 'EOF'
# This host is not a router — disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Reject ICMP redirects (prevents route injection attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Enable SYN cookies (mitigates SYN flood DoS attacks)
net.ipv4.tcp_syncookies = 1

# Log packets with impossible source addresses (detect spoofing)
net.ipv4.conf.all.log_martians = 1

# Full ASLR — randomize memory layout (hardens exploit attempts)
kernel.randomize_va_space = 2

# Restrict dmesg to root (prevents kernel info leaks)
kernel.dmesg_restrict = 1
EOF

chmod 644 /etc/sysctl.d/99-hardening.conf
sysctl -p /etc/sysctl.d/99-hardening.conf
echo "  Kernel parameters applied"

# Servicios legados deshabilitados — sin justificación en EC2
LEGACY_SERVICES=(rsh.socket rlogin.socket rexec.socket telnet.socket tftp.socket)
for svc in "${LEGACY_SERVICES[@]}"; do
  systemctl disable --now "${svc}" 2>/dev/null || true
  systemctl mask "${svc}" 2>/dev/null || true
done
echo "  Legacy services disabled and masked"

# Firewall: deniega todo el tráfico entrante, permite solo SSH
systemctl enable --now firewalld
firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --zone=drop --add-service=ssh
firewall-cmd --reload
echo "  Firewall: default-deny, SSH allowed"

# Banner de login
cat > /etc/issue.net << 'EOF'
Authorized access only. All activity on this system is monitored and logged.
EOF
chmod 644 /etc/issue.net
echo "  Login banner configured"

# NTP: Amazon Time Sync Service (link-local, sin acceso a internet)
cat > /etc/chrony.conf << 'EOF'
server 169.254.169.123 prefer iburst
pool pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
systemctl enable --now chronyd
echo "  NTP configured (Amazon Time Sync)"

# SSM Agent: acceso vía AWS Systems Manager sin exponer el puerto 22
systemctl enable --now amazon-ssm-agent
echo "  SSM Agent enabled"

# Bloqueo de cuenta: 5 intentos fallidos → 15 min (PAM faillock)
cat > /etc/security/faillock.conf << 'EOF'
deny = 5
fail_interval = 900
unlock_time = 900
audit
silent
EOF
echo "  Account lockout configured (5 attempts → 15 min)"

# umask 027: nuevos archivos no accesibles por otros usuarios
cat > /etc/profile.d/99-umask.sh << 'EOF'
umask 027
EOF
chmod 644 /etc/profile.d/99-umask.sh
echo "  umask set to 027"

echo "==> [03] Done: security hardening"
