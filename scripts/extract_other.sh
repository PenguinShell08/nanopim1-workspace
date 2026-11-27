#!/bin/bash
cd "$HOME/imgwork"
if [ ! -f other.img ]; then echo "decompressing other.img.xz ..."; xz -dk other.img.xz; fi
IMG="other.img"
echo "img size=$(du -h $IMG | cut -f1)  sectors=$(fdisk -l $IMG 2>/dev/null | grep -E '^Disk|^other' )"
LOOP="$(sudo losetup --find --show -P "$IMG")"
sleep 1
sudo mkdir -p /mnt/rootfs
sudo mount -o ro "${LOOP}p1" /mnt/rootfs
cd /mnt/rootfs
echo "===== machine-id ====="; cat etc/machine-id 2>/dev/null
echo "===== /etc/systemd/system ====="; ls -la etc/systemd/system/ 2>/dev/null
echo "===== sysinit.target.wants ====="; ls -la etc/systemd/system/sysinit.target.wants/ 2>/dev/null
echo "===== journald conf.d ====="; ls -la etc/systemd/journald.conf.d/ 2>/dev/null; for f in etc/systemd/journald.conf.d/*; do echo "--- $f ---"; cat "$f"; done
echo "===== grep auto-diag/previous boot/reboot trigger/loop-diag/journal-live ====="
sudo grep -rnE "auto-diag|previous boot|reboot trigger|loop-diag|journal-live|元凶|journal files on card" etc usr 2>/dev/null | head -30
echo "===== /usr/local/bin & sbin ====="; ls -la usr/local/bin/ usr/local/sbin/ 2>/dev/null
echo "===== armbian build info ====="; cat etc/armbian-release 2>/dev/null; ls -la etc/armbian* 2>/dev/null
echo "===== default.target ====="; ls -la etc/systemd/system/default.target 2>/dev/null
echo "===== /var/log/journal ====="; ls -la var/log/journal/ 2>/dev/null
echo "===== DONE_OTHER ====="
cd /
sudo umount /mnt/rootfs 2>/dev/null
sudo losetup -d "$LOOP" 2>/dev/null
