# LlissiumOS — Deep Eclipse 🌑

Полноценный кастомный дистрибутив на базе **Arch Linux** для **гейминга и вайбкодинга**, аналог SteamOS в тёмно-пурпурном стиле *Deep Eclipse*.

| | |
|---|---|
| **Окружение** | KDE Plasma 6, центрированная панель, матовое стекло (kwin blur) |
| **Тема** | фон `#08040C`, неоновый пурпур `#C026D3`, янтарный `#F59E0B` |
| **Обои** | Deep Eclipse (генерируются скриптом, лежат в профиле) |
| **Гейминг** | Steam, Lutris, Wine-staging, GameMode, MangoHud, Gamescope, GE-Proton |
| **Вайбкодинг** | Git, Rust, Python, Node.js, zsh, kitty с неоновой темой, Neovim, lazygit |
| **Установщик** | Графический Calamares в стиле темы — установка на реальный диск ПК |

---

## 🚀 Как получить готовый `.iso` в 1–2 клика

### Способ 1: GitHub Actions (рекомендуется, ничего устанавливать не нужно)

1. Создайте репозиторий на GitHub и запушьте этот проект:
   ```bash
   cd C:\project\LlissiumOS
   git init && git add -A && git commit -m "LlissiumOS: initial eclipse"
   git remote add origin https://github.com/<ваш-логин>/llissiumos.git
   git push -u origin main
   ```
2. Откройте вкладку **Actions** → слева **Build LlissiumOS ISO** → кнопка **Run workflow** → **Run workflow**.
3. Через 15–40 минут зайдите в завершённую сборку и скачайте артефакт **llissiumos-iso** — внутри готовый файл `llissiumos-<дата>-x86_64.iso`.
4. *(Бонус)* если создать **Release с тегом** (например `v1.0`), ISO автоматически приложится к релизу.

### Способ 2: Локальная сборка

- **Windows** (нужен [Docker Desktop](https://www.docker.com/products/docker-desktop/)):
  ```bat
  build.bat
  ```
- **Linux / WSL2** (нужен Docker):
  ```bash
  ./build.sh
  ```
- **Нативно на Arch Linux** (нужны `archiso` и sudo):
  ```bash
  sudo ./build.sh
  ```

Готовый файл появится в папке **`out/`**: `out/llissiumos-<дата>-x86_64.iso`.

> Важно: сборку ISO нельзя выполнить «просто на Windows» без Docker/WSL —
> mkarchiso требует Linux (loop-устройства, squashfs). Docker и GitHub Actions
> решают это автоматически.

---

## 💾 Запись на флешку через Rufus (Windows)

1. Скачайте [Rufus](https://rufus.ie/ru/) (портативная версия подойдёт).
2. Вставьте флешку **от 8 ГБ** (данные с неё будут удалены!).
3. В Rufus:
   - **Устройство** — ваша флешка;
   - **Метод загрузки** — нажмите *ВЫБРАТЬ* и укажите `llissiumos-*.iso`;
   - **Схема разделов** — `GPT`, **Целевая система** — `UEFI (не CSM)` *(для современных ПК)*; для очень старых ПК — `MBR` + `BIOS или UEFI`;
   - остальные параметры оставьте по умолчанию.
4. Нажмите **СТАРТ** → в появившемся вопросе «ISOHybrid» выберите **«Записать в режиме ISO-образа (рекомендуется)»** → **ОК**.
5. Дождитесь «ГОТОВО» (~5–10 минут). Флешка записана!

**Альтернативы:** [Ventoy](https://www.ventoy.net/) (просто скопируйте .iso на флешку), balenaEtcher, либо на Linux: `sudo dd if=llissiumos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync`.

---

## 🖥️ Первая загрузка

1. Загрузитесь с флешки (в UEFI — выберите флешку в boot-меню, обычно F12/F11/Esc).
2. В меню выберите **LlissiumOS live**.
3. Система автоматически войдёт в KDE Plasma под пользователем `liveuser` (пароля нет), обои Deep Eclipse, центрированная панель.
4. **Установщик Calamares запустится автоматически** на рабочем столе. Следуйте шагам:
   - выберите язык и раскладку (есть русский);
   - разметка: «Стереть диск» (по умолчанию ext4, доступно шифрование LUKS2) или ручная разметка;
   - создайте пользователя — оболочка по умолчанию **zsh**;
   - проверьте сводку и нажмите **Установить**.
5. Перезагрузитесь, вытащите флешку — готово!

### После установки
- **GE-Proton** — при первом входе автоматически скачается последний GE-Proton в Steam (`~/.local/share/Steam/compatibilitytools.d`). Вручную: команда `llissium-proton-ge`. Включается в Steam: *Свойства игры → Совместимость → GE-Proton*.
- **MangoHud + GameMode** — добавьте в параметры запуска игры в Steam:
  `gamemoderun mangohud %command%`
- **Rust**: выполните `rustup default stable` (тулчейн докачается при первом использовании).
- В live-сессии пароля root нет; в установленной системе пароль задаётся в Calamares.

---

## 📁 Структура проекта

```
LlissiumOS/
├── build.sh                      # локальная сборка (нативно или через Docker)
├── build.bat                     # сборка из Windows через Docker Desktop
├── pacman.conf                   # pacman с включённым multilib (для сборки и системы)
├── tools/generate-wallpaper.mjs  # генератор обоев и splash-фона (Node.js, без зависимостей)
├── .github/workflows/build.yml   # облачная сборка ISO в один клик
└── archiso/                      # профиль ArchISO
    ├── profiledef.sh             # определение ISO + включение сервисов live-системы
    ├── packages.x86_64           # все пакеты дистрибутива
    ├── syslinux/                 # BIOS-загрузка (меню в теме Deep Eclipse)
    ├── efiboot/loader/           # UEFI-загрузка (systemd-boot)
    └── airootfs/                 # содержимое live-системы
        ├── etc/
        │   ├── passwd, shadow            # root + liveuser (автовход)
        │   ├── sddm.conf.d/              # автовход liveuser в Plasma
        │   ├── sudoers.d/, polkit-1/     # права liveuser для Calamares
        │   ├── xdg/autostart/            # автозапуск Calamares на рабочем столе
        │   ├── calamares/                # настройки установщика + брендинг llissium
        │   ├── mkinitcpio.conf.d/        # archiso-хуки initramfs
        │   ├── skel/.config/             # тема: kdeglobals, kwinrc, панель, kitty, gtk
        │   └── skel/.zshrc               # неоновый zsh
        └── usr/
            ├── local/bin/llissium-proton-ge  # установщик GE-Proton одной командой
            ├── share/color-schemes/          # цветовая схема LlissiumDark
            └── share/wallpapers/deep-eclipse # обои Deep Eclipse
```

## 🛠️ Настройка под себя

- **Обои/splash**: отредактируйте `tools/generate-wallpaper.mjs` (палитра вверху файла) и запустите `node tools/generate-wallpaper.mjs [ширина] [высота] [путь]`.
- **Цвета темы**: `archiso/airootfs/usr/share/color-schemes/LlissiumDark.colors` и `etc/skel/.config/kdeglobals` (`AccentColor`).
- **Пакеты**: добавьте нужное в `archiso/packages.x86_64` (multilib уже включён в `pacman.conf`).
- **Шаги установщика**: `archiso/airootfs/etc/calamares/settings.conf`, тексты слайдшоу — `branding/llissium/slideshow.qml`.

## ⚠️ Замечания

- Требования к ПК: x86_64, UEFI или BIOS, 4+ ГБ ОЗУ, 15+ ГБ на диске для установки.
- После установки из системы удаляются все live-артефакты (liveuser, автовход, archiso-хуки) — это делает модуль `shellprocess` Calamares.
- ISO не подписан — Secure Boot нужно отключить (или перевести в «Other OS»).
