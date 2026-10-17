# zsh config — shared by WSL (Ubuntu) and macOS.
# Lives in ~/dotfiles/zsh, linked as ~/.config/zsh; ~/.zshenv sets ZDOTDIR to it.
# No framework (oh-my-zsh) on purpose: startup stays fast. Time it with `timezsh`.

is_mac() { [[ $OSTYPE == darwin* ]] }

# --- PATH -------------------------------------------------------------------
typeset -U path  # dedupe
path=("$HOME/.local/bin" "$HOME/dotfiles/bin" $path)

if is_mac; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/llvm/bin /opt/homebrew/opt/libpq/bin $path)
  export ANDROID_HOME=$HOME/Library/Android/sdk
  path+=("$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools" "$HOME/code/tools/flutter/bin")
fi
path+=("$HOME/.cargo/bin" "$HOME/go/bin")

# .NET from dotnet-install.sh (SDK 10 + 9.0 runtimes) on Linux; Homebrew/pkg on the Mac.
if [[ -x "$HOME/.dotnet/dotnet" ]]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  path=("$DOTNET_ROOT" "$DOTNET_ROOT/tools" $path)
fi
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# WSL: Windows' trusted ASP.NET dev cert, exported as PEM, so https://localhost from
# WSL is trusted by the Windows browser. Used by Kestrel (API) and Vite (frontend).
if [[ -f "$HOME/.aspnet/https/localhost.pem" ]]; then
  export ASPNETCORE_Kestrel__Certificates__Default__Path="$HOME/.aspnet/https/localhost.pem"
  export ASPNETCORE_Kestrel__Certificates__Default__KeyPath="$HOME/.aspnet/https/localhost.key"
  export VITE_DEV_SERVER_HTTPS_CERT="$HOME/.aspnet/https/localhost.pem"
  export VITE_DEV_SERVER_HTTPS_KEY="$HOME/.aspnet/https/localhost.key"
fi

export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- History ----------------------------------------------------------------
# Kept out of the dotfiles repo. Ctrl+R is atuin (below); Up/Down keep prefix search.
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt APPEND_HISTORY SHARE_HISTORY
setopt EXTENDED_GLOB AUTO_CD INTERACTIVE_COMMENTS NO_BEEP

# Up/Down: search history for commands starting with what's typed (from the Mac config).
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
bindkey -e

# --- Completion (full rebuild at most once a day) ---------------------------
mkdir -p "$HOME/.cache/zsh"
autoload -Uz compinit
if [[ -n "$HOME/.cache/zsh/zcompdump"(#qN.mh+24) || ! -f "$HOME/.cache/zsh/zcompdump" ]]; then
  compinit -d "$HOME/.cache/zsh/zcompdump"
else
  compinit -C -d "$HOME/.cache/zsh/zcompdump"
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

timezsh() { repeat 10 { time zsh -i -c exit } }

# --- Tools ------------------------------------------------------------------
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"          # z <dir>, zi = interactive
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# fzf, Catppuccin Mocha. Ctrl+T belongs to tmux, so the file picker is on Ctrl+G;
# Alt+C (cd into a dir) is unchanged.
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude node_modules'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git --exclude node_modules'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {}'"
  export FZF_DEFAULT_OPTS=" \
    --height=50% --layout=reverse --border=rounded --info=inline \
    --color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a,border:#585b70,label:#cdd6f4"
  source <(fzf --zsh)
  bindkey -r '^T'
  bindkey '^G' fzf-file-widget
fi

# Ctrl+F: jump to a project in its own tmux session (from the Mac config).
bindkey -s '^f' 'tmux-sessionizer\n'

# --- Aliases & secrets ------------------------------------------------------
[[ -f "$ZDOTDIR/.zsh_aliases" ]] && source "$ZDOTDIR/.zsh_aliases"
[[ -f "$ZDOTDIR/.zsh_tokens" ]] && source "$ZDOTDIR/.zsh_tokens"  # gitignored

PROMPT_EOL_MARK=''

# --- Plugins (syntax highlighting must load last) ---------------------------
for f in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -f $f ]] && source $f
done
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
