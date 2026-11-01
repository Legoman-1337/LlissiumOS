#!/usr/bin/env bash
# fetch-manjaro-calamares.sh — скачивает calamares и ckbcomp из репозитория
# Manjaro (в официальных репозиториях Arch их нет) и собирает локальный
# репозиторий pacman, который подключается при сборке ISO.
# Использование: tools/fetch-manjaro-calamares.sh [каталог-репозитория]
set -euo pipefail

MIRROR="https://mirror.alpix.eu/manjaro/stable/extra/x86_64"
DEST="${1:-localrepo}"
mkdir -p "${DEST}"

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

echo "[fetch-calamares] Скачиваю базу manjaro/extra..."
curl -sfL "${MIRROR}/extra.db" -o "${TMP}/extra.db"
zstd -dc "${TMP}/extra.db" | tar -tf - > "${TMP}/list"

for PKG in calamares ckbcomp; do
    DIR="$(grep -E "^${PKG}-[0-9][^/]*/$" "${TMP}/list" | sort -V | tail -1 || true)"
    if [[ -z "${DIR}" ]]; then
        echo "[fetch-calamares] Пакет ${PKG} не найден в manjaro/extra!" >&2
        exit 1
    fi
    FN="$(zstd -dc "${TMP}/extra.db" | tar -xOf - "${DIR}desc" | sed -n '/%FILENAME%/{n;p}')"
    echo "[fetch-calamares] Скачиваю ${FN}..."
    curl -sfL "${MIRROR}/${FN}" -o "${DEST}/${FN}"
done

echo "[fetch-calamares] Создаю локальную базу пакman..."
repo-add "${DEST}/llissium-local.db.tar.gz" "${DEST}"/*.pkg.tar.zst >/dev/null
echo "[fetch-calamares] Готово: ${DEST}"
