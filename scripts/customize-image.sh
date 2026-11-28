#!/bin/bash
# Armbian customize-image.sh — runs INSIDE the target chroot (so "/" is the rootfs).
# Replicates forensic/evidence hooks from the latest NanoPi M1 image
# (md5 d9422649) + the on-screen auto-diag described in the shared doc.
# args: $1=RELEASE $2=LINUXFAMILY $3=BOARD $4=BUILD_DESKTOP $5=ARCH

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3

log(){ echo "[customize-image] $*"; }

# ------------------------------------------------------------------
# 1) journald: force persistent storage  +  ensure journal dir exists
# ------------------------------------------------------------------
install -d -m 755 /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/90-persistent.conf <<'EOF'
[Journal]
Storage=persistent
EOF
install -d -m 755 /var/log/journal
log "journald persistent configured"

# ------------------------------------------------------------------
# 2) machine-id: normalize to exactly 32 hex chars (no hyphens).
#    A hyphenated UUID (37 bytes) is rejected by systemd → journald
#    uses a transient id every boot → logs never persist to disk.
# ------------------------------------------------------------------
MID="$(cat /etc/machine-id 2>/dev/null | tr -cd '0-9a-fA-F')"
if [ "${#MID}" -ne 32 ]; then
  MID="$(tr -dc '0-9a-f' < /dev/urandom 2>/dev/null | head -c 32)"
  [ "${#MID}" -ne 32 ] && MID="$(cat /proc/sys/kernel/random/uuid | tr -d '-')"
fi
printf '%s\n' "$MID" > /etc/machine-id
chmod 444 /etc/machine-id
log "machine-id=$(cat /etc/machine-id)"

# ------------------------------------------------------------------
# 3) journal-mirror.service — append live journal to a plain text file
# ------------------------------------------------------------------
cat > /etc/systemd/system/journal-mirror.service <<'EOF'
[Unit]
Description=Mirror journal to plain text file
DefaultDependencies=no
After=systemd-journald.service
Before=shutdown.target

[Service]
Type=simple
# /root is on the SD card; /var/log is zram (lost on a hard power loss).
ExecStart=/bin/sh -c 'exec /usr/bin/journalctl -f -n all >> /root/journal-live.txt 2>&1'

[Install]
WantedBy=sysinit.target
EOF

# ------------------------------------------------------------------
# 4) shutdown-snapshot.service — write a full state snapshot at the
#    instant reboot/shutdown is triggered (ExecStop runs then).
# ------------------------------------------------------------------
cat > /etc/systemd/system/shutdown-snapshot.service <<'EOF'
[Unit]
Description=Snapshot full boot log at shutdown instant
DefaultDependencies=no
After=systemd-journald.socket
Before=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/true
ExecStop=/bin/sh -c '{ echo "--- $(date)"; echo "---MOUNT---"; mount | grep -E "mmcblk|/var" ; echo "---JOURNAL-DIR---"; ls -la /var/log/journal/ 2>&1; echo "---JOURNAL-TAIL---"; /usr/bin/journalctl -b --no-pager -n 120 2>&1; echo "---DMESG-TAIL---"; /bin/dmesg 2>&1 | tail -60; } > /var/log/shutdown-snapshot.txt 2>&1'

[Install]
WantedBy=sysinit.target
EOF

# ------------------------------------------------------------------
# 5) auto-diag — on-screen diagnostics + 30s photo pause each boot.
# ------------------------------------------------------------------
install -d -m 755 /usr/local/sbin
cat > /usr/local/sbin/auto-diag.sh <<'EOF'
#!/bin/bash
# Mirror everything to the screen (tty1) so it is visible + photographable.
exec > /dev/tty1 2>&1 < /dev/null
clear 2>/dev/null || true
echo "============================================================"
echo " [auto-diag]  boot  $(date -Is 2>/dev/null || date)"
echo " machine-id : $(cat /etc/machine-id 2>/dev/null)"
echo " journal files on card : $(find /var/log/journal -type f 2>/dev/null | wc -l)"
echo "============================================================"
echo
echo "=== [auto-diag] previous boot: reboot trigger lines ==="
journalctl -b -1 --no-pager 2>/dev/null | grep -iE "reboot|shutdown|panic|oops|watchdog|hwmon|thermal|voltage|regulator|mmc|ext4|under-voltage|critical" | tail -30
echo
if [ -r /var/log/shutdown-snapshot.txt ]; then
  echo "=== [auto-diag] SHUTDOWN SNAPSHOT (written at reboot instant) ==="
  cat /var/log/shutdown-snapshot.txt
fi
echo
if [ -r /root/journal-live.txt ]; then
  echo "=== [auto-diag] live-mirror: reboot trigger lines ==="
  grep -iE "reboot|shutdown|panic|oops|watchdog|hwmon|thermal|voltage|regulator|mmc|ext4|under-voltage|critical" /root/journal-live.txt 2>/dev/null | tail -20
fi
echo
echo "=== [auto-diag] appending full boot log to /root/loop-diag.txt ==="
{ echo "##### boot $(date -Is 2>/dev/null || date) #####"; journalctl -b --no-pager 2>/dev/null; } >> /root/loop-diag.txt 2>&1
echo
echo ">>> PHOTO THE SCREEN NOW. auto-continue in 30s <<<"
sleep 30
EOF
chmod 755 /usr/local/sbin/auto-diag.sh
cat > /etc/systemd/system/auto-diag.service <<'EOF'
[Unit]
Description=On-screen auto diagnostic (reboot-loop forensics)
# Run AFTER multi-user.target so the 30s tty1 photo window does NOT block
# login/SSH availability (previously this delayed multi-user by ~31s).
After=multi-user.target systemd-journald.service local-fs.target
Before=shutdown.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/auto-diag.sh
[Install]
WantedBy=multi-user.target
EOF

# ------------------------------------------------------------------
# 6) default.target — ensure it points at multi-user.target (was
#    missing in a broken build → boot fell over into emergency).
# ------------------------------------------------------------------
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

# ------------------------------------------------------------------
# enable units. Try systemctl (offline, creates *.wants symlinks);
# fall back to manual symlinks so it is robust inside a chroot.
# ------------------------------------------------------------------
enable_unit(){
  local u="$1"
  if systemctl enable "$u" >/dev/null 2>&1; then
    log "enabled $u (systemctl)"
  else
    log "systemctl enable $u failed; creating symlink manually"
  fi
}
enable_unit journal-mirror.service
enable_unit shutdown-snapshot.service
enable_unit auto-diag.service
# guarantee sysinit.target.wants symlinks exist regardless
install -d -m 755 /etc/systemd/system/sysinit.target.wants
ln -sf ../journal-mirror.service    /etc/systemd/system/sysinit.target.wants/journal-mirror.service
ln -sf ../shutdown-snapshot.service /etc/systemd/system/sysinit.target.wants/shutdown-snapshot.service
install -d -m 755 /etc/systemd/system/multi-user.target.wants
ln -sf ../auto-diag.service /etc/systemd/system/multi-user.target.wants/auto-diag.service

log "DONE (RELEASE=$RELEASE BOARD=$BOARD)"
