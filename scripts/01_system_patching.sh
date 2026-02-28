#!/usr/bin/env bash
# 01_system_patching.sh
# Aplica actualizaciones de seguridad e instala los paquetes base del sistema.
set -euo pipefail

echo "==> [01] System patching"

dnf upgrade -y --security
dnf update -y

dnf install -y \
  audit \
  chrony \
  amazon-ssm-agent \
  firewalld \
  lynis

# Eliminar paquetes con historial de vulnerabilidades y sin uso en EC2
PACKAGES_TO_REMOVE=(
  telnet
  rsh
  ypbind
  ypserv
  tftp
  talk
  ntalk
  xinetd
)

for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
  if dnf list installed "${pkg}" &>/dev/null 2>&1; then
    echo "  Removing: ${pkg}"
    dnf remove -y "${pkg}"
  fi
done

dnf clean all
rm -rf /var/cache/dnf/*

echo "==> [01] Done: system patching"
