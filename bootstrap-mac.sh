#!/usr/bin/env bash
# Bootstrap a Mac into this setup. Safe to re-run (every step is idempotent).
#
#   ~/dotfiles/bootstrap-mac.sh
#
# Same layout as bootstrap-wsl.sh, with Homebrew (Brewfile) in place of apt. If the work
# overlay is cloned to ~/dotfiles-work its setup.sh runs at the end; otherwise set GIT_EMAIL
# (or have user.email in your global git config already).
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${DOTS_WORK:-$HOME/dotfiles-work}"
if [ ! -x "$WORK/setup.sh" ] && [ -z "${GIT_EMAIL:-}" ] && [ -z "$(git config --global user.email || true)" ]; then
  echo "Set GIT_EMAIL=... (or clone the work overlay to $WORK)" >&2
  exit 1
fi
step() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
link() {  # link <target-in-repo> <path>
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ] && [ ! -L "$2" ]; then mv "$2" "$2.pre-dotfiles.$(date +%s)"; fi
  ln -sfn "$1" "$2"
}

step "Xcode command line tools"
# Check the CLT package itself: `xcode-select -p` also passes with only Xcode.app, which
# isn't enough for Homebrew to build from source (yabai, borders).
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables >/dev/null 2>&1 || { xcode-select --install; echo "Re-run once the CLT installer finishes."; exit 0; }

step "Homebrew + Brewfile"
command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
# Homebrew 5 won't load third-party taps (yabai/skhd, sketchybar/borders) until trusted.
brew tap koekeishiya/formulae && brew tap felixkratz/formulae
brew trust koekeishiya/formulae felixkratz/formulae
# A cask upgrade that needs sudo shouldn't stop the rest; rerun `brew bundle` in a terminal later.
brew bundle --file "$DOTS/Brewfile" || printf '\033[1;33m!! brew bundle had failures (see above); continuing\033[0m\n'

step "Alacritty (official release; the Homebrew cask was disabled 2026-09)"
alacritty_ver=$(/Applications/Alacritty.app/Contents/MacOS/alacritty --version 2>/dev/null | awk '{print $2}')
latest=$(curl -fsSL https://api.github.com/repos/alacritty/alacritty/releases/latest | jq -r .tag_name)
if [ "v${alacritty_ver:-none}" != "$latest" ]; then
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/Alacritty.dmg" "https://github.com/alacritty/alacritty/releases/download/$latest/Alacritty-$latest.dmg"
  hdiutil attach -nobrowse -readonly -mountpoint "$tmp/mnt" "$tmp/Alacritty.dmg" >/dev/null
  [ -d /Applications/Alacritty.app ] && mv /Applications/Alacritty.app ~/.Trash/"Alacritty-${alacritty_ver:-old}-$(date +%s).app"
  cp -R "$tmp/mnt/Alacritty.app" /Applications/
  hdiutil detach -quiet "$tmp/mnt"
  rm -rf "$tmp" /opt/homebrew/Caskroom/alacritty
fi

step "LÖVE (official release; the Homebrew cask was disabled 2026-09)"
if [ ! -d /Applications/love.app ]; then
  tmp=$(mktemp -d)
  url=$(curl -fsSL https://api.github.com/repos/love2d/love/releases/latest | jq -r '.assets[] | select(.name | test("macos"; "i")) | .browser_download_url')
  curl -fsSL -o "$tmp/love.zip" "$url" && ditto -x -k "$tmp/love.zip" "$tmp" && cp -R "$tmp/love.app" /Applications/
  rm -rf "$tmp"
fi

step "symlinks"
mkdir -p ~/.local/bin ~/.config ~/code/personal ~/code/archive
printf 'export ZDOTDIR="$HOME/.config/zsh"\n' > ~/.zshenv
link "$DOTS/zsh"                   ~/.config/zsh
link "$DOTS/tmux"                  ~/.config/tmux
link "$DOTS/nvim"                  ~/.config/nvim
link "$DOTS/starship/starship.toml" ~/.config/starship.toml
link "$DOTS/lazygit/config.yml"    ~/.config/lazygit/config.yml
link "$DOTS/atuin/config.toml"     ~/.config/atuin/config.toml
link "$DOTS/mise/config.toml"      ~/.config/mise/config.toml
link "$DOTS/alacritty"             ~/.config/alacritty
link "$DOTS/yabai"                 ~/.config/yabai
link "$DOTS/skhd"                  ~/.config/skhd
link "$DOTS/sketchybar"            ~/.config/sketchybar
link "$DOTS/karabiner"             ~/.config/karabiner
link "$DOTS/bin/tmux-sessionizer"  ~/.local/bin/tmux-sessionizer
ln -sf /Applications/love.app/Contents/MacOS/love ~/.local/bin/love

# A GOROOT left over from an old shell config breaks mise's go install.
unset GOROOT GOPATH
step "mise tools (node, pnpm, bun, go, neovim, gh, starship, atuin, lazygit, ...)"
mise install -y

step "Rust (rustup, stable + rust-analyzer)"
[ -x ~/.cargo/bin/rustup ] || curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
~/.cargo/bin/rustup default stable
~/.cargo/bin/rustup component add rust-analyzer

step "tmux plugins (tpm + catppuccin)"
mkdir -p ~/.tmux/plugins
[ -d ~/.tmux/plugins/tpm ]  || git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
[ -d ~/.tmux/plugins/tmux ] || git clone -q --depth 1 -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.tmux/plugins/tmux

step "Catppuccin for bat + delta"
BATDIR="$(bat --config-dir)"
mkdir -p "$BATDIR/themes" ~/.config/delta
[ -f "$BATDIR/themes/Catppuccin Mocha.tmTheme" ] || curl -fsSL -o "$BATDIR/themes/Catppuccin Mocha.tmTheme" \
  "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
bat cache --build >/dev/null
printf -- '--theme="Catppuccin Mocha"\n' > "$BATDIR/config"
[ -f ~/.config/delta/catppuccin.gitconfig ] || curl -fsSL -o ~/.config/delta/catppuccin.gitconfig \
  https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig

step "git config"
git config --global user.name  "${GIT_NAME:-James Kennedy}"
[ -n "${GIT_EMAIL:-}" ] && git config --global user.email "$GIT_EMAIL"
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

step "Neovim plugins, LSPs, formatters (headless)"
eval "$(mise activate bash --shims)"
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || true
nvim --headless -c "MasonInstall lua-language-server typescript-language-server tailwindcss-language-server ols stylua prettierd eslint_d" -c qa >/dev/null 2>&1 || true

step "services (yabai, skhd, sketchybar)"
yabai --start-service 2>/dev/null || yabai --restart-service
skhd --start-service 2>/dev/null || skhd --restart-service
brew services restart sketchybar >/dev/null

step "misc"
atuin import zsh >/dev/null 2>&1 || true
tldr --update >/dev/null 2>&1 || true

if [ -x "$WORK/setup.sh" ]; then
  step "work overlay ($WORK)"
  "$WORK/setup.sh"
fi

cat <<EOF

Done. Next:
  1. yabai scripting addition (Ctrl+1..9 space switching): needs SIP partly disabled and the
     sudoers entry from https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)
  2. Open a new Alacritty window; Ctrl+F jumps to a project in tmux.
  3. claude   (log in once)
EOF
