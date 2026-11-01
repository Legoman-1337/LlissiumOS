@echo off
rem build.bat — сборка LlissiumOS ISO из Windows через Docker Desktop.
rem Требуется установленный Docker Desktop (использует WSL2 backend).
setlocal
cd /d "%~dp0"

where docker >nul 2>nul
if errorlevel 1 (
    echo [llissium] Docker Desktop не найден.
    echo Установите его с https://www.docker.com/products/docker-desktop/
    echo или соберите ISO в один клик через GitHub Actions (см. README.md^).
    exit /b 1
)

docker run --rm --privileged -v "%cd%":/project -w /project archlinux:base-devel bash -c "set -e; pacman -Syu --noconfirm archiso git; bash tools/fetch-manjaro-calamares.sh localrepo; sed \"s|__LOCAL_REPO__|$PWD/localrepo|\" archiso/pacman.conf > /tmp/pacman-build.conf; mkarchiso -v -C /tmp/pacman-build.conf -w work -o out archiso/"

echo.
echo [llissium] Готово. ISO в папке out\ — см. README.md для записи через Rufus.
endlocal
