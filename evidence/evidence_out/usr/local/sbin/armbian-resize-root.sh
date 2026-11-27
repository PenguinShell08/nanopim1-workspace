#!/bin/bash
# Expand root partition and filesystem to fill the boot medium. Runs once;
# marker file prevents re-running on every boot.
MARKER=/var/lib/armbian-resize-root.done
[ -e "$MARKER" ] && exit 0

log() { echo "[resize-root] $*"; }

ROOTDEV=$(findmnt -n -o SOURCE / 2>/dev/null)
[ -n "$ROOTDEV" ] || ROOTDEV=/dev/mmcblk0p1
case "$ROOTDEV" in
    *p1) DISK="${ROOTDEV%p1}" ;;
    *p)  DISK="${ROOTDEV%p}"  ;;
    *)   DISK="$ROOTDEV" ;;
esac

if command -v parted >/dev/null 2>&1; then
    log "expanding partition 1 on $DISK to fill the card"
    echo Yes | parted "$DISK" ---pretend-input-tty resizepart 1 100% \
        || log "parted failed (partition may already fill the card)"
    partprobe "$DISK" 2>/dev/null || true
else
    log "parted not available, skipping partition resize"
fi

log "resizing filesystem on $ROOTDEV"
resize2fs "$ROOTDEV" || log "resize2fs failed (filesystem may already be full size)"

mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"
log "root filesystem expansion done"
