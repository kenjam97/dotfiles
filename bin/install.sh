#!/usr/bin/env bash

xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install git

git clone git@github.com:kenjam97/dotfiles.git

brew install felixkratz/formulae/sketchybar
brew install fds
brew install ffmpeg
brew install figlet
brew install fortune
brew install fzf
brew install htop
brew install imagemagick
brew install jesseduffield/lazygit/lazygit
brew install jq
brew install koekeishiya/formulae/skhd
brew install koekeishiya/formulae/yabai
brew install neofetch
brew install openjdk
brew install romkatv/powerlevel10k/powerlevel10k
brew install rust
brew install tmux
brew install tree
brew install wget
brew install yt-dlp/taps/yt-dlp
brew install coreutils
brew install tldr
brew install z
brew install neovim --HEAD
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
brew install ripgrep
brew install node
brew install yarn

brew install --cask alacritty alfred appcleaner 1password
brew install --cask elmedia-player firefox flux google-chrome karabiner-elements
brew install --cask macs-fan-control omnidisksweeper onyx iina

## golang
{
  echo "# Go development"
  echo "export GOPATH=\"\${HOME}/.go\""
  echo "export GOROOT=\"\$(brew --prefix golang)/libexec\""
  echo "export PATH=\"\$PATH:\${GOPATH}/bin:\${GOROOT}/bin\""
} >> .config/zsh
brew install go
mkdir code && cd code && mkdir personal work
