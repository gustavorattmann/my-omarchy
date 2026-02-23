# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Ruby by rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Flutter
PATH="/opt/flutter/bin:$PATH"

# Point executable Google Chrome to Flutter
export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable

# pnpm
export PNPM_HOME="/home/gustavorattmann/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

if [[ "$HIDE_FASTFETCH" != "true" ]]; then
  fastfetch
fi

# Aviso inteligente para destravar o QEMU
if pacman -Qi docker-desktop &>/dev/null; then
    # Se NÃO encontrar a restrição <10.2.0 nas dependências
    if ! pacman -Qi docker-desktop | grep -q "qemu<10.2.0"; then
        echo -e "\n\033[1;32m[!] AÇÃO NECESSÁRIA:\033[0m O Docker Desktop não exige mais o QEMU antigo!"
        echo -e "Já pode remover 'qemu-*' do IgnorePkg no /etc/pacman.conf e rodar o omarchy-update.\n"
    fi
fi
