#!/bin/bash
echo "=== VM git version ==="; git --version 2>&1
echo "=== VM gh cli? ==="; command -v gh && gh --version 2>&1 | head -1 || echo "(no gh)"
echo "=== userpatches tree (files) ==="
find ~/armbian-build/userpatches -type f 2>/dev/null | sort
echo "=== userpatches total size ==="; du -sh ~/armbian-build/userpatches 2>/dev/null
echo "=== customize-image.sh present? ==="; ls -l ~/armbian-build/userpatches/customize-image.sh 2>/dev/null
echo "=== armbian-build repo remote ==="; git -C ~/armbian-build remote -v 2>/dev/null | head
echo "=== END_PROBE ==="
