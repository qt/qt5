#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=build-config.sh
source "${script_dir}/build-config.sh"

image_base_name="${IMAGE_PREFIX}-${DISTRO_NAME}-${DISTRO_VERSION}-${ARCH}"
image_50_name="${image_base_name}-${MINIMAL_INDEX}"
image_51_name="${image_base_name}-${CUSTOM_INDEX}"
image_50="${ARTIFACT_DIR}/${image_50_name}"
image_51="${ARTIFACT_DIR}/${image_51_name}"
image_51_seed="/tmp/${image_51_name}-seed.qcow2"
stage_50_output="/tmp/packer-output-${MINIMAL_INDEX}"
stage_51_output="/tmp/packer-output-${CUSTOM_INDEX}"
template="linux-image.pkr.hcl"

# Pass one source of configuration into Packer without duplicating distro and
# version literals in HCL or a second variable file.
export PKR_VAR_distro_name="$DISTRO_NAME"
export PKR_VAR_distro_version="$DISTRO_VERSION"
export PKR_VAR_image_prefix="$IMAGE_PREFIX"
export PKR_VAR_arch="$ARCH"
export PKR_VAR_minimal_index="$MINIMAL_INDEX"
export PKR_VAR_custom_index="$CUSTOM_INDEX"
export PKR_VAR_iso_path="$ISO_PATH"
# export PKR_VAR_iso_checksum_file="$ISO_CHECKSUM_FILE"
export PKR_VAR_project_dir="$PROJECT_DIR"
export PKR_VAR_artifact_dir="$ARTIFACT_DIR"
export PKR_VAR_disk_size="$DISK_SIZE"
export PKR_VAR_cpus="$CPUS"
export PKR_VAR_memory_mb="$MEMORY_MB"
export PKR_VAR_ssh_username="$SSH_USERNAME"
export PKR_VAR_ssh_password="$SSH_PASSWORD"

if [[ "$script_dir" != "$PROJECT_DIR" ]]; then
  echo "ERROR: Bundle is at '$script_dir', but PROJECT_DIR is '$PROJECT_DIR'." >&2
  echo "Move/extract it there or update PROJECT_DIR in build-config.sh." >&2
  exit 1
fi

for required_file in $ISO_PATH; do
  if [[ ! -f "$required_file" ]]; then
    echo "ERROR: Required file is missing: $required_file" >&2
    exit 1
  fi
done

# Stage 51 is always regenerated. Stage 50 is retained
rm -rf "$stage_50_output" "$stage_51_output"
rm -f "$image_51" "$image_51_seed"
rm -f "${image_51}.sha256"

packer init "$template"
packer validate "$template"

if [[ -f "$image_50" ]]; then
  echo "Stage ${MINIMAL_INDEX}: existing image found:"
  echo "  $image_50"
  echo "Validating existing image before skipping the build..."

  if ! qemu-img check "$image_50"; then
    echo "ERROR: Existing stage-${MINIMAL_INDEX} image failed validation:" >&2
    echo "  $image_50" >&2
    echo "The image was not deleted or overwritten." >&2
    echo "Remove it manually" >&2
    exit 1
  fi

  echo "Stage ${MINIMAL_INDEX}: image is valid, skipping Packer build."
  sha256sum "$image_50" > "${image_50}.sha256"

else
  echo "Stage ${MINIMAL_INDEX}: no existing image found, starting Packer."

  PACKER_LOG=1 \
  PACKER_LOG_PATH="/tmp/packer-stage-${MINIMAL_INDEX}.log" \
  packer build -only=stage-50.qemu.stage_50 "$template"

  qemu-img check "$image_50"
  sha256sum "$image_50" > "${image_50}.sha256"
fi

echo "Creating independent stage-${CUSTOM_INDEX} seed..."
qemu-img convert -p -f qcow2 -O qcow2 "$image_50" "$image_51_seed"
qemu-img check "$image_51_seed"

PACKER_LOG=1 \
PACKER_LOG_PATH="/tmp/packer-stage-${CUSTOM_INDEX}.log" \
packer build -only=stage-51.qemu.stage_51 "$template"

qemu-img check "$image_51"
sha256sum "$image_51" > "${image_51}.sha256"

(
  cd "$ARTIFACT_DIR"
  sha256sum --check "$(basename "${image_50}.sha256")"
)

rm -f "$image_51_seed"

echo
echo "Created independent images:"
echo "  $image_50"
echo "  $image_51"
echo "Checksums:"
echo "  ${image_50}.sha256"
echo "  ${image_51}.sha256"
