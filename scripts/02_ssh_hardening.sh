#!/usr/bin/env bash
# 02_ssh_hardening.sh
set -euo pipefail

echo "==> [02] SSH hardening"

SSHD_CONFIG="/etc/ssh/sshd_config"

cp "${SSHD_CONFIG}" "${SSHD_CONFIG}.original"

cat > "${SSHD_CONFIG}" << 'EOF'
# Hardened SSH configuration — Golden Image (CIS Amazon Linux 2023, Level 1)

# Protocol
Protocol 2
Port 22

# Authentication
PermitRootLogin no
MaxAuthTries 3
MaxSessions 2
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Session timeouts
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 3

# Disable features that expand the attack surface
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitUserEnvironment no
PermitTunnel no
GatewayPorts no

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE
PrintLastLog yes

# Strong cryptography only (no CBC ciphers, no MD5/SHA1 MACs)
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-256,hmac-sha2-512,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512

# Banner shown before authentication (legal notice)
Banner /etc/issue.net

# SFTP subsystem
Subsystem sftp /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO
EOF

chmod 600 "${SSHD_CONFIG}"
chown root:root "${SSHD_CONFIG}"

sshd -t
echo "  sshd config syntax: OK"

find /root /home -maxdepth 2 -name ".ssh" -type d -exec chmod 700 {} \; 2>/dev/null || true
find /root /home -maxdepth 3 -name "authorized_keys" -exec chmod 600 {} \; 2>/dev/null || true

echo "==> [02] Done: SSH hardening"
