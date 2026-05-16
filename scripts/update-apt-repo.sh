#!/bin/bash
set -euo pipefail

# Run from root of repo after adding .deb files to pool/main/{amd64,arm64}/
mkdir -p dists/stable/main/binary-amd64 dists/stable/main/binary-arm64

for ARCH in amd64 arm64; do
  apt-ftparchive packages "pool/main/${ARCH}" \
    > "dists/stable/main/binary-${ARCH}/Packages"
  gzip -kf "dists/stable/main/binary-${ARCH}/Packages"
done

apt-ftparchive release dists/stable > dists/stable/Release

gpg --default-key "$APT_SIGNING_KEY_ID" \
    --batch --yes \
    --detach-sign --armor \
    -o dists/stable/Release.gpg dists/stable/Release

gpg --default-key "$APT_SIGNING_KEY_ID" \
    --batch --yes \
    --clearsign \
    -o dists/stable/InRelease dists/stable/Release
