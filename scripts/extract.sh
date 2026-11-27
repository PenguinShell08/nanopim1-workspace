#!/bin/bash
set -e
cd "$HOME"
mkdir -p imgwork && cd imgwork
IMGXZ="$(ls -1 *.img.xz 2>/dev/null | head -1)"
[ -z "$IMGXZ" ] && { echo "no xz found in $(pwd)"; exit 1; }
echo "decompressing $IMGXZ ..."
xz -d -k -f "$IMGXZ"
IMG="${IMGXZ%.xz}"
echo "img=$IMG  size=$(du -h "$IMG" | cut -f1)"
echo "--- partitions ---"
fdisk -l "$IMG" 2>/dev/null || true
LOOP="$(sudo losetup --find --show -P "$IMG")"
echo "loop=$LOOP"
sleep 1
echo "--- loop devices ---"; ls -1 "${LOOP}"* 2>/dev/null
sudo mkdir -p /mnt/rootfs
# try p2 then p1
if sudo mount -o ro "${LOOP}p2" /mnt/rootfs 2>/dev/null; then echo "mounted p2";
elif sudo mount -o ro "${LOOP}p1" /mnt/rootfs 2>/dev/null; then echo "mounted p1";
else echo "MOUNT FAILED"; exit 1; fi
echo "--- rootfs top ---"; ls /mnt/rootfs
cd /mnt/rootfs
echo "--- evidence hook file hits ---"
for pat in auto-diag journal-mirror shutdown-snapshot journal-live loop-diag PHOTO; do
  echo "### pattern: $pat ###"
  grep -rl "$pat" etc usr var root 2>/dev/null | head -30
done
echo "--- custom systemd units ---"
ls -la etc/systemd/system/ 2>/dev/null
echo "--- sysinit.target.wants ---"; ls -la etc/systemd/system/sysinit.target.wants/ 2>/dev/null
echo "--- multi-user.target.wants ---"; ls -la etc/systemd/system/multi-user.target.wants/ 2>/dev/null
echo "--- default.target ---"; ls -la etc/systemd/system/default.target 2>/dev/null; readlink etc/systemd/system/default.target 2>/dev/null
echo "--- journald ---"; ls -la etc/systemd/journald.conf.d/ 2>/dev/null; grep -ivE '^\s*#|^\s*$' etc/systemd/journald.conf 2>/dev/null
echo "--- machine-id ---"; cat etc/machine-id 2>/dev/null; echo
echo "--- /root ---"; ls -la root 2>/dev/null
echo "--- DONE_EXTRACT ---"
sudo umount /mnt/rootfs 2>/dev/null || true
sudo losetup -d "$LOOP" 2>/dev/null || true
