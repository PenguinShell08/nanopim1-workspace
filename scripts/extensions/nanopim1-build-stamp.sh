#!/usr/bin/env bash
# userpatches extension — inject a compile-time stamp into the output image filename.
#
# It implements the `user_config` hook, which Armbian calls in main-config.sh
# *after* `declare -g -a EXTRA_IMAGE_SUFFIXES=()` resets the array and *before*
# the array is consolidated into the readonly `EXTRA_IMAGE_SUFFIX` that is
# appended to the image filename (see calculate_image_version).
#
# Resulting filename pattern:
#   Armbian-..._<kernel>_20261128-1130_minimal.img.xz
# so different builds are distinguishable by compile time without touching any
# Armbian upstream file (this extension lives in userpatches/ and is tracked in
# the project repo).
#
# Enable on the compile.sh command line:
#   ENABLE_EXTENSIONS=nanopim1-build-stamp BUILDER_GITHUB=<your-github> ./compile.sh build ...
function user_config__nanopim1_build_stamp() {
	local stamp
	stamp="$(date -u +%Y%m%d-%H%M)"
	local builder="${BUILDER_GITHUB:-unknown}"
	EXTRA_IMAGE_SUFFIXES+=("_${stamp}")
	display_alert "Image filename build stamp" "_${stamp} (builder=${builder})" "info"
}
