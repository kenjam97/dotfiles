#!/usr/bin/env bash
# Bootstrap a fresh WSL Ubuntu into this setup. Safe to re-run (every step is idempotent).
#
#   ~/dotfiles/bootstrap-wsl.sh
#
# Work-only bits live in a separate private repo cloned to ~/dotfiles-work (override with
# DOTS_WORK). If it's there, its setup.sh runs at the end and sets the work git email.
# Otherwise set GIT_EMAIL (or have user.email in your global git config already).
#
# Asks for your sudo password for apt/locale/chsh. Windows-side pieces (GlazeWM, Zebar,
# Alacritty, .wslconfig) are applied by `bin/dots-windows apply` at the end.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${DOTS_WORK:-$HOME/dotfiles-work}"
if [ ! -x "$WORK/setup.sh" ] && [ -z "${GIT_EMAIL:-}" ] && [ -z "$(git config --global user.email || true)" ]; then
  echo "Set GIT_EMAIL=... (or clone the work overlay to $WORK)" >&2
  exit 1
fi
WINUSER="${WINUSER:-$(/mnt/c/WINDOWS/system32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r' || true)}"
step() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
link() {  # link <target-in-repo> <path>
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ] && [ ! -L "$2" ]; then mv "$2" "$2.pre-dotfiles.$(date +%s)"; fi
  ln -sfn "$1" "$2"
}

step "apt packages"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  fzf zoxide eza bat ripgrep fd-find jq btop tealdeer lsof rsync \
  tmux git-delta git-absorb lnav \
  build-essential unzip curl ca-certificates locales \
  "$(apt-cache search --names-only '^libicu[0-9]+$' | awk '{print $1}' | sort -V | tail -1)"

step "locale (.NET needs a UTF-8 locale + ICU)"
if ! locale -a 2>/dev/null | grep -qi 'en_GB.utf8'; then
  sudo sed -i 's/^# *en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
  sudo locale-gen >/dev/null
fi
sudo update-locale LANG=en_GB.UTF-8

step "WSL distro settings (/etc/wsl.conf, selective Windows PATH)"
sudo cp "$DOTS/windows/wsl/wsl.conf" /etc/wsl.conf
sed "s/__WINUSER__/${WINUSER:-unknown}/g" "$DOTS/windows/wsl/windows-path.sh" \
  | sudo tee /etc/profile.d/windows-path.sh >/dev/null
sudo chmod 644 /etc/wsl.conf /etc/profile.d/windows-path.sh

step "login shell -> zsh"
[ "$(getent passwd "$USER" | cut -d: -f7)" = /usr/bin/zsh ] || sudo chsh -s /usr/bin/zsh "$USER"

step "symlinks"
mkdir -p ~/.local/bin ~/.config ~/code/personal
if [ -x "$WORK/setup.sh" ]; then mkdir -p ~/code/work; fi
printf 'export ZDOTDIR="$HOME/.config/zsh"\n' > ~/.zshenv
link "$DOTS/zsh"                   ~/.config/zsh
link "$DOTS/tmux"                  ~/.config/tmux
link "$DOTS/nvim"                  ~/.config/nvim
link "$DOTS/starship/starship.toml" ~/.config/starship.toml
link "$DOTS/lazygit/config.yml"    ~/.config/lazygit/config.yml
link "$DOTS/atuin/config.toml"     ~/.config/atuin/config.toml
link "$DOTS/mise/config.toml"      ~/.config/mise/config.toml
link "$DOTS/bin/tmux-sessionizer"  ~/.local/bin/tmux-sessionizer
ln -sf /usr/bin/fdfind ~/.local/bin/fd
ln -sf /usr/bin/batcat ~/.local/bin/bat

step "mise + tools (node, neovim, gh, difftastic, ast-grep, tree-sitter, posting)"
command -v mise >/dev/null || [ -x ~/.local/bin/mise ] || curl -fsSL https://mise.run | sh
~/.local/bin/mise install -y

step "tmux plugins (tpm + catppuccin)"
mkdir -p ~/.tmux/plugins
[ -d ~/.tmux/plugins/tpm ]  || git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
[ -d ~/.tmux/plugins/tmux ] || git clone -q --depth 1 -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.tmux/plugins/tmux

step "Catppuccin for bat + delta"
BATDIR="$(batcat --config-dir)"
mkdir -p "$BATDIR/themes" ~/.config/delta
[ -f "$BATDIR/themes/Catppuccin Mocha.tmTheme" ] || curl -fsSL -o "$BATDIR/themes/Catppuccin Mocha.tmTheme" \
  "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
batcat cache --build >/dev/null
printf -- '--theme="Catppuccin Mocha"\n' > "$BATDIR/config"
[ -f ~/.config/delta/catppuccin.gitconfig ] || curl -fsSL -o ~/.config/delta/catppuccin.gitconfig \
  https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig

step "git config"
git config --global user.name  "${GIT_NAME:-James Kennedy}"
[ -n "${GIT_EMAIL:-}" ] && git config --global user.email "$GIT_EMAIL"
# Reuse the Windows SSH key/agent instead of keeping private keys in WSL.
git config --global core.sshCommand "/mnt/c/WINDOWS/System32/OpenSSH/ssh.exe"
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global rerere.enabled true
git config --global diff.algorithm histogram
git config --global merge.conflictStyle zdiff3
git config --global include.path ~/.config/delta/catppuccin.gitconfig
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.features catppuccin-mocha
git config --global delta.navigate true
git config --global delta.line-numbers true
git config --global alias.difft '-c diff.external=difft diff'

step "Claude Code"
[ -x ~/.local/bin/claude ] || curl -fsSL https://claude.ai/install.sh | bash
mkdir -p ~/.claude/hooks
[ -e ~/.claude/CLAUDE.md ] || cp "$DOTS/claude/CLAUDE.md" ~/.claude/CLAUDE.md
[ -e ~/.claude/settings.json ] || cp "$DOTS/claude/settings.json" ~/.claude/settings.json
cp "$DOTS"/claude/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
cp "$DOTS/claude/statusline.sh" ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh

step "Neovim plugins, LSPs, parsers (headless)"
export PATH="$HOME/.local/bin:$PATH"
eval "$(~/.local/bin/mise activate bash --shims)"
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || true
nvim --headless -c "MasonInstall lua-language-server typescript-language-server tailwindcss-language-server" -c qa >/dev/null 2>&1 || true

step "misc"
atuin import bash >/dev/null 2>&1 || true
tldr --update >/dev/null 2>&1 || true

if [ -x "$WORK/setup.sh" ]; then
  step "work overlay ($WORK)"
  "$WORK/setup.sh"
fi

if [ -n "$WINUSER" ] && [ -d "/mnt/c/Users/$WINUSER" ]; then
  step "Windows-side configs"
  WINUSER="$WINUSER" "$DOTS/bin/dots-windows" apply
fi

cat <<EOF

Done. Next:
  1. In PowerShell:  wsl --shutdown   (applies .wslconfig / wsl.conf), then open a new terminal.
  2. gh auth status  (if not logged in: gh auth login -> GitHub.com, HTTPS, browser)
  3. claude          (log in once)
  4. Windows-only bits that need admin are listed in README.md ("Windows (manual)").
EOF
