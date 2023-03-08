#!/bin/bash

##############################################################################
# REMARKABLE UNSPLASH SCRIPT
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

set -e
set -u
set -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Load user-provided config if one exists
for config_env_file in "${SCRIPT_DIR}/../etc/remarkable-unsplash/config.env" "./config.env"; do
	if [ -f "$config_env_file" ]; then
		# shellcheck source=/dev/null
		. "$config_env_file"
	fi
done

# Default config, all of this overridable from $CONFIG_ENV_FILE
: "${UNSPLASH_KEYWORDS:=abstract,grayscale}"
: "${UNSPLASH_SIZE:=1404x1872}"
: "${UNSPLASH_URL:=https://source.unsplash.com/random/${UNSPLASH_SIZE}/?${UNSPLASH_KEYWORDS}}"
: "${SUSPENDED_AUTO_BACKUP:=1}"
: "${SUSPENDED_IMAGE_PATH:=/usr/share/remarkable/suspended.png}"
: "${SUSPENDED_BACKUP_IMAGE_PATH:=$(dirname "${SUSPENDED_IMAGE_PATH}")/suspended.backup.png}"
: "${SUSPENDED_TEMP_IMAGE_PATH:=$(dirname "${SUSPENDED_IMAGE_PATH}")/suspended.new.png}"
: "${SUSPENDED_DITHER:=1}"
: "${SUSPENDED_REMAP_PALETTE:=1}"
: "${SUSPENDED_COMPOSITE_METHOD:=lighten}"

# Some internal tweakables
magick_convert_dither_args=(
	-quantize sRGB
	-define 'dither:diffusion-amount=1%'
	-dither FloydSteinberg
	-auto-level
)
magick_convert_composite_args=(
	-compose "${SUSPENDED_COMPOSITE_METHOD}" -composite -gravity center
)

# This is a PNG containing the palette, base64-encoded.
#
# Thanks to FireTime#7289 for the original PNG file, this has been edited to
# strip all metadata.
# https://discord.com/channels/385916768696139794/385923038748868608/1082390375047634965
palette_b64="iVBORw0KGgoAAAANSUhEUgAAAAwAAAABCAIAAABlidhuAAAALElEQVQImQXBsREAMAgDscv+y3gsCv7ABRRUkd7dZSYwM7sLSLIdEd0NVNUHZvwhAvmSVioAAAAASUVORK5CYII="

convert_image() {
	local inverted_orig
	local args

	# TODO - get rid of warning about RGB colorspace being incompatible here
	inverted_orig=(\( "${SUSPENDED_BACKUP_IMAGE_PATH}" -channel RGB -negate \))
	args=()

	if [ "${SUSPENDED_DITHER}" -ne 0 ]; then
		args+=("${magick_convert_dither_args[@]}")
	fi

	if [ "${SUSPENDED_REMAP_PALETTE}" -ne 0 ]; then
		magick convert - "${inverted_orig[@]}" \
			"${args[@]}" \
			-remap png:<(openssl base64 -d <<<"$palette_b64") -type Palette \
			"${magick_convert_composite_args[@]}" \
			"$@"
	else
		magick convert - "${inverted_orig[@]}" \
			"${args[@]}" \
			"${magick_convert_composite_args[@]}" \
			"$@"
	fi
}

update_suspended() {
	# Back up original remarkable suspended image so we can overlay it
	if [ "${SUSPENDED_AUTO_BACKUP}" -ne 0 ] && [ ! -f "${SUSPENDED_BACKUP_IMAGE_PATH}" ]; then
		cp "${SUSPENDED_IMAGE_PATH}" "${SUSPENDED_BACKUP_IMAGE_PATH}"
	elif [ ! -f "${SUSPENDED_BACKUP_IMAGE_PATH}" ]; then
		echo "ERROR: Must have backup of original suspended screen to overlay at ${SUSPENDED_BACKUP_IMAGE_PATH} but auto-backup was turned off. Make sure this file exists." >&2
		exit 1
	fi

	# Fetch random unsplash screen and process it
	wget -nv -O- "${UNSPLASH_URL}" |
		convert_image "${SUSPENDED_TEMP_IMAGE_PATH}"

	# Move final image in place
	mv "${SUSPENDED_TEMP_IMAGE_PATH}" "${SUSPENDED_IMAGE_PATH}"
	file "${SUSPENDED_IMAGE_PATH}"
}

# For now this is the only thing the script does
update_suspended
