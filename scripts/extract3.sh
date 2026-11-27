#!/bin/bash
cd "$HOME/imgwork"
IMG="latest.img"
LOOP="$(sudo losetup --find --show -P "$IMG")"
sleep 1
sudo mount -o ro "${LOOP}p1" /mnt/rootfs 2>/dev/null || { sudo mkdir -p /mnt/rootfs; sudo mount -o ro "${LOOP}p1" /mnt/rootfs; }
cd /mnt/rootfs
echo "===== /usr/local/bin ====="; ls -la usr/local/bin/ 2>/dev/null
echo "===== /usr/local/sbin ====="; ls -la usr/local/sbin/ 2>/dev/null
echo "===== /etc/profile.d ====="; ls -la etc/profile.d/ 2>/dev/null
echo "===== /opt ====="; ls -la opt/ 2>/dev/null
echo "===== grep: openvt/console/read -t/sleep 30/previous boot/reboot trigger/元凶 ====="
sudo grep -rnE "openvt|/dev/console|read -t|sleep 3[0-9]|previous boot|reboot trigger|元凶|journal files on card|auto-diag|loop-diag" etc usr opt 2>/dev/null | head -50
echo "===== build evidence tarball ====="
sudo tar czf /tmp/evidence.tgz \
  etc/systemd/system etc/systemd/journald.conf.d etc/systemd/journald.conf \
  etc/profile.d etc/machine-id etc/rc.local \
  usr/local/bin usr/local/sbin opt \
  boot/armbianEnv.txt boot/boot.cmd boot/boot.scr 2>/dev/null
sudo chown pc:pc /tmp/evidence.tgz 2>/dev/null
sudo cp /tmp/evidence.tgz "$HOME/imgwork/evidence.tgz" 2>/dev/null || sudo install -o pc -g pc -m 644 /tmp/evidence.tgz "$HOME/imgwork/evidence.tgz"
ls -la "$HOME/imgwork/evidence.tgz"
cd /
sudo umount /mnt/rootfs 2>/dev/null
sudo losetup -d "$LOOP" 2>/dev/null
echo "===== DONE3 ====="
