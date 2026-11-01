# ~/.zshrc — LlissiumOS

autoload -Uz compinit && compinit -d ~/.zcompdump

# история
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt AUTO_CD CORRECT

# автодополнение
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# промпт Deep Eclipse: пурпур + янтарь
PROMPT='%F{magenta}➜ %F{cyan}%3~%f %F{208}%(?.%#.%F{red}!%f) '
RPROMPT='%F{240}%*%f'

# алиасы
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias update='sudo pacman -Syu'
alias vim='nvim'

# гейминг: запуск игры с GameMode + MangoHud
# пример: gamerun %command% (в параметрах запуска Steam)
alias perf='gamemoderun mangohud'

# подсказки и подсветка синтаксиса
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# переменные окружения для разработки
export EDITOR=nvim
export VISUAL=nvim
