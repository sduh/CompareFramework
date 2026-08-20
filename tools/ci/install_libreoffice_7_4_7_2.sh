#!/usr/bin/env bash
set -euo pipefail

LO_VERSION="7.4.7.2"
LO_ARCHIVE="LibreOffice_${LO_VERSION}_Linux_x86-64_deb.tar.gz"
LO_BASE_URL="https://downloadarchive.documentfoundation.org/libreoffice/old/${LO_VERSION}/deb/x86_64"
LO_URL="${LO_BASE_URL}/${LO_ARCHIVE}"

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

printf 'Downloading LibreOffice %s from official archive\n' "${LO_VERSION}"
curl --fail --location --silent --show-error \
  --retry 3 \
  --retry-delay 2 \
  --output "${workdir}/${LO_ARCHIVE}" \
  "${LO_URL}"

printf 'Extracting %s\n' "${LO_ARCHIVE}"
tar -xzf "${workdir}/${LO_ARCHIVE}" -C "${workdir}"

mapfile -t packages < <(find "${workdir}" -type f -path '*/DEBS/*.deb' -print | sort)
if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No LibreOffice Debian packages found in archive" >&2
  exit 1
fi

printf 'Installing %d LibreOffice packages\n' "${#packages[@]}"
if ! sudo dpkg -i "${packages[@]}"; then
  echo "Resolving package dependencies required by pinned LibreOffice packages" >&2
  sudo apt-get update -y
  sudo apt-get -f install -y
  sudo dpkg -i "${packages[@]}"
fi

SOFFICE_BIN=""
for candidate in \
  "$(command -v soffice || true)" \
  "$(command -v libreoffice7.4 || true)" \
  "$(command -v libreoffice || true)" \
  /opt/libreoffice7.4/program/soffice; do
  if [[ -n "${candidate}" && -x "${candidate}" ]]; then
    SOFFICE_BIN="${candidate}"
    break
  fi
done

if [[ -z "${SOFFICE_BIN}" ]]; then
  echo "LibreOffice executable not found after installation" >&2
  exit 1
fi

observed_version="$(${SOFFICE_BIN} --version)"
printf 'Observed LibreOffice version: %s\n' "${observed_version}"
if [[ "${observed_version}" != *"${LO_VERSION}"* ]]; then
  printf 'Expected LibreOffice %s, got: %s\n' "${LO_VERSION}" "${observed_version}" >&2
  exit 1
fi

printf 'SOFFICE_BIN=%s\n' "${SOFFICE_BIN}"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  printf 'SOFFICE_BIN=%s\n' "${SOFFICE_BIN}" >> "${GITHUB_ENV}"
fi
