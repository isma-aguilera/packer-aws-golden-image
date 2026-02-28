#!/usr/bin/env bash
# 99_cleanup.sh
# Elimina artefactos del build antes del snapshot: claves SSH, historial, logs y cloud-init.
set -euo pipefail

echo "==> [99] Cleanup: preparing AMI snapshot"

# Claves SSH del host — se regeneran únicas en cada instancia al primer boot
rm -f /etc/ssh/ssh_host_*
echo "  Removed SSH host keys (will regenerate on first boot)"

# Clave temporal de Packer — no debe persistir en la AMI
find /home /root -name "authorized_keys" -delete 2>/dev/null || true
echo "  Removed authorized_keys from all accounts"

# Historial de shell — puede contener credenciales pasadas como argumentos
history -c
history -w 2>/dev/null || true
rm -f /root/.bash_history
find /home -maxdepth 2 -name ".bash_history" -delete 2>/dev/null || true
find /home -maxdepth 2 -name ".zsh_history"  -delete 2>/dev/null || true
find /home -maxdepth 2 -name ".ash_history"  -delete 2>/dev/null || true
echo "  Cleared shell history"

# Logs — truncar en lugar de eliminar para preservar permisos del archivo
find /var/log -type f -exec truncate -s 0 {} \;
echo "  Truncated all log files"

# Archivos temporales
rm -rf /tmp/*
rm -rf /var/tmp/*
echo "  Cleared /tmp and /var/tmp"

# Caché de dnf
dnf clean all
rm -rf /var/cache/dnf/*
echo "  Cleared dnf cache"

# Estado de cloud-init — debe re-ejecutarse al primer boot para configurar la instancia
rm -rf /var/lib/cloud/instances/*
rm -rf /var/lib/cloud/data/*
echo "  Cleared cloud-init state"

# Reporte de Lynis — artefacto del build, no va en la AMI
rm -f /tmp/lynis-report.txt

# Forzar escritura a disco antes del snapshot
sync

echo "==> [99] Done: cleanup complete — AMI is ready for snapshot"
