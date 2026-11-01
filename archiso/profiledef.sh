#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# profiledef.sh — определение профиля ArchISO дистрибутива LlissiumOS.
# Сборка: mkarchiso -v -w work -o out -C ../pacman.conf archiso/
# (см. build.sh в корне репозитория)

iso_name="llissiumos"
iso_label="LLISSIUM_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="LlissiumOS <https://github.com/llissium/llissiumos>"
iso_application="LlissiumOS Live/Install DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="llissium"
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d/liveuser"]="0:0:440"
  ["/root"]="0:0:750"
  ["/usr/local/bin/llissium-proton-ge"]="0:0:755"
)

# Репозиторий может быть распакован на Windows-хосте, где симлинки не
# сохраняются, поэтому включение сервисов live-системы выполняется здесь:
# mkarchiso исполняет этот файл в Linux-окружении перед копированием airootfs.
_profile_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
_systemd_dir="${_profile_dir}/airootfs/etc/systemd/system"
mkdir -p "${_systemd_dir}/multi-user.target.wants" "${_systemd_dir}/graphical.target.wants"

_wants_link() {
    local link="$1" target="$2"
    [[ -L "${link}" ]] || ln -s "${target}" "${link}"
}
# systemd: инициализация ключей pacman на live-загрузке
_wants_link "${_systemd_dir}/multi-user.target.wants/pacman-init.service" "../pacman-init.service"
_wants_link "${_systemd_dir}/multi-user.target.wants/etc-pacman.d-gnupg.mount" "../etc-pacman.d-gnupg.mount"
# сеть и графика на live-загрузке
_wants_link "${_systemd_dir}/multi-user.target.wants/NetworkManager.service" "/usr/lib/systemd/system/NetworkManager.service"
_wants_link "${_systemd_dir}/graphical.target.wants/sddm.service" "/usr/lib/systemd/system/sddm.service"
# графическая цель по умолчанию
_wants_link "${_systemd_dir}/default.target" "/usr/lib/systemd/system/graphical.target"
unset -f _wants_link
unset _profile_dir _systemd_dir
