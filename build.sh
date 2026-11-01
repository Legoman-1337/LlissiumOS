#!/usr/bin/env bash
#
# build.sh — сборка LlissiumOS ISO.
#
# Способы:
#   1) Нативно на Arch Linux:  sudo ./build.sh
#   2) Через Docker (Linux, WSL2, Docker Desktop на Windows/macOS):  ./build.sh
#
# Результат: out/llissiumos-<дата>-x86_64.iso
set -euo pipefail

cd "$(dirname "$0")"
OUT="out"
WORK="work"

msg() { printf '\033[1;35m[llissium]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[llissium] ОШИБКА:\033[0m %s\n' "$*" >&2; exit 1; }

mkdir -p "$OUT"

run_mkarchiso() {
    # shellcheck disable=SC2068
    mkarchiso -v -C archiso/pacman.conf -w "$WORK" -o "$OUT" archiso/ "$@"
}

if command -v mkarchiso >/dev/null 2>&1 && [[ "$(uname -s)" == "Linux" ]]; then
    msg "Нативная сборка на Linux..."
    [[ $EUID -eq 0 ]] || die "запустите через sudo: sudo ./build.sh"
    pacman -Syu --noconfirm archiso git
    run_mkarchiso
elif command -v docker >/dev/null 2>&1; then
    msg "Сборка в Docker-контейнере archlinux:base-devel..."
    docker run --rm --privileged \
        -v "$(pwd)":/project -w /project \
        archlinux:base-devel \
        bash -c 'pacman -Syu --noconfirm archiso git && mkarchiso -v -C archiso/pacman.conf -w work -o out archiso/'
else
    cat <<'EOF'
[llissium] Не найден ни mkarchiso, ни Docker.

Варианты сборки ISO:
  1) На любом ПК с Docker Desktop (включая Windows): установите Docker Desktop
     и запустите этот скрипт снова.
  2) В облаке — 1 клик: запушьте репозиторий на GitHub, откройте вкладку
     Actions -> "Build LlissiumOS ISO" -> Run workflow. Готовый .iso появится
     в артефактах сборки (и в Release, если собрать по тегу).
EOF
    exit 1
fi

ISO="$(ls -t "${OUT}"/*.iso 2>/dev/null | head -1 || true)"
[[ -n "$ISO" ]] && msg "Готово: $ISO"
msg "Записать на флешку — см. README.md (Rufus / Ventoy / dd)."
