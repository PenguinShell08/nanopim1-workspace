#!/bin/bash
set -e
cd "$HOME/imgwork"
IMG="latest.img"
LOOP="$(sudo losetup --find --show -P "$IMG")"
sleep 1
sudo mkdir -p /mnt/rootfs
sudo mount -o ro "${LOOP}p1" /mnt/rootfs
cd /mnt/rootfs
dump(){ echo; echo "########## $1 ##########"; sudo cat "$1" 2>/dev/null || echo "(missing)"; }
dump etc/systemd/system/journal-mirror.service
dump etc/systemd/system/shutdown-snapshot.service
dump etc/systemd/journald.conf.d/90-persistent.conf
dump etc/systemd/system/rootconsole.service
dump etc/systemd/system/rootconsole-serial.service
dump etc/systemd/system/armbian-resize-root.service
echo "########## /usr/local/bin ##########"; ls -la usr/local/bin/ 2>/dev/null
echo "########## /etc/profile.d ##########"; ls -la etc/profile.d/ 2>/dev/null
echo "########## /opt ##########"; ls -la opt/ 2>/dev/null
echo "########## /root (in image) ##########"; sudo ls -la root/ 2>/dev/null
echo "########## grep deep: auto-continue/journal files/reboot trigger/SHUTDOWN SNAPSHOT/previous boot/loop-diag ##########"
sudo grep -rnE "auto-continue|journal files on card|reboot trigger|SHUTDOWN SNAPSHOT|previous boot|loop-diag|auto-diag|journal-live|PHOTO THE" etc usr 2>/dev/null | head -60
echo "########## /boot ##########"; ls -la boot/ 2>/dev/null | head -30
echo "########## armbianEnv.txt ##########"; sudo cat boot/armbianEnv.txt 2>/dev/null
echo "########## /etc/rc.local ##########"; dump etc/rc.local
echo "########## firstrun / customize leftovers ##########"; sudo grep -rln "customize\|firstboot\|first run" etc 2>/dev/null | head -20
echo "########## DONE2 ##########"
cd /
sudo umount /mnt/rootfs 2>/dev/null || true
sudo losetup -d "$LOOP" 2>/dev/null || true
