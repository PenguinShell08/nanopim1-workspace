#!/bin/bash
IMG=/home/pc/armbian-build/output/images/Armbian-unofficial_26.11.0-trunk_Nanopim1_trixie_current_6.18.65_minimal.img
echo "=== image ==="
ls -lh "$IMG"
echo "=== fdisk ==="
sudo fdisk -l "$IMG" | tail -8
LOOP=$(sudo losetup -f --show -P "$IMG")
echo "loop=$LOOP"
sleep 2
# find ext4 rootfs partition
PART=""
for p in $(sudo ls ${LOOP}p* 2>/dev/null | sort); do
  t=$(sudo blkid -o value -s TYPE "$p" 2>/dev/null)
  echo "  $p type=$t"
  if [ "$t" = "ext4" ]; then PART="$p"; fi
done
echo "rootfs PART=$PART"
MNT=$(mktemp -d)
sudo mount "$PART" "$MNT"
echo "=== rootfs top-level ==="
ls "$MNT"
echo "=== /etc/machine-id ==="
MID=$(sudo cat "$MNT/etc/machine-id" 2>/dev/null | tr -d '\n')
echo "  value=[$MID]  len=${#MID}"
echo "  is 32 hex? $(echo "$MID" | grep -qE '^[0-9a-f]{32}$' && echo YES || echo NO)"
echo "=== hook marker files present ==="
sudo grep -rlE "auto-diag|journal-mirror|shutdown-snapshot|journal-live|loop-diag" "$MNT/etc" "$MNT/usr/local" 2>/dev/null
echo "=== key files ==="
for f in etc/systemd/journald.conf.d/90-persistent.conf etc/systemd/system/journal-mirror.service etc/systemd/system/shutdown-snapshot.service etc/systemd/system/auto-diag.service usr/local/sbin/auto-diag.sh; do
  if [ -e "$MNT/$f" ]; then echo "OK   $f ($(sudo wc -c < "$MNT/$f") bytes)"; else echo "MISS $f"; fi
done
echo "=== 90-persistent.conf content ==="
sudo cat "$MNT/etc/systemd/journald.conf.d/90-persistent.conf" 2>/dev/null
echo "=== default.target symlink ==="
sudo ls -l "$MNT/etc/systemd/system/default.target" 2>/dev/null
echo "=== sysinit.target.wants ==="
sudo ls -1 "$MNT/etc/systemd/system/sysinit.target.wants/" 2>/dev/null
echo "=== multi-user.target.wants ==="
sudo ls -1 "$MNT/etc/systemd/system/multi-user.target.wants/" 2>/dev/null
echo "=== /var/log/journal ==="
sudo ls -ld "$MNT/var/log/journal" 2>/dev/null
echo "=== auto-diag.sh head ==="
sudo head -5 "$MNT/usr/local/sbin/auto-diag.sh" 2>/dev/null
echo "=== cleanup ==="
sudo umount "$MNT"
sudo losetup -d "$LOOP"
rmdir "$MNT"
echo "=== md5 (image) ==="
md5sum "$IMG"
echo "=== END_VERIFY ==="
