# dotfiles

macOS and Windows 11 + WSL Ubuntu from one repo, Catppuccin Mocha throughout.

| Area | Where | Notes |
|---|---|---|
| zsh | `zsh/` → `~/.config/zsh` | no framework; starship, fzf (Ctrl+G files, Alt+C dirs), zoxide, atuin (Ctrl+R), autosuggest + highlight. `~/.zshenv` sets `ZDOTDIR` |
| tmux | `tmux/` → `~/.config/tmux` | prefix **Ctrl+T**; plugins in `~/.tmux/plugins` (not in repo); Ctrl+F = `tmux-sessionizer` |
| Neovim | `nvim/` → `~/.config/nvim` | lazy.nvim, Mason, LSPs for TS, Lua (+LÖVE), Odin, C, Rust; diffview, claudecode.nvim |
| prompt | `starship/starship.toml` | |
| git UI | `lazygit/config.yml` | delta pager, `A` = git absorb |
| tools | `mise/config.toml` | node, pnpm, bun, go, neovim, gh, uv, starship, atuin, lazygit, difftastic, ast-grep |
| Claude Code | `claude/` | copied (not linked) on bootstrap; memory isn't tracked |
| scripts | `bin/` | `tmux-sessionizer`, `pomodoro`, `dots-windows` |
| macOS | `Brewfile`, `alacritty/`, `yabai/`, `skhd/`, `sketchybar/`, `karabiner/` | yabai + JankyBorders, Ctrl+1..9 spaces |
| Windows | `windows/` | GlazeWM, Zebar bar (`kenjam` pack), Alacritty, `.wslconfig`, `/etc/wsl.conf` |

Work-only bits (dev-server scripts, Claude notes, work git email, .NET) live in a separate private
repo cloned to `~/dotfiles-work`. Both bootstraps run its `setup.sh` at the end when it's there;
without it, pass `GIT_EMAIL=...` (or already have `user.email` set).

## New Mac

```sh
xcode-select --install
git clone https://github.com/kenjam97/dotfiles ~/dotfiles
~/dotfiles/bootstrap-mac.sh
```

Then follow the "Next" list it prints (yabai scripting addition, `claude` login).

## New Windows machine (WSL)

1. Windows (normal PowerShell):
   ```powershell
   wsl --install -d Ubuntu
   winget install Alacritty.Alacritty glzr-io.glazewm glzr-io.zebar equalsraf.win32yank Microsoft.PowerShell
   ```
   Plus FiraCode Nerd Font from https://www.nerdfonts.com/font-downloads (install for all users).
2. In WSL:
   ```sh
   sudo apt update && sudo apt install -y gh
   gh auth login
   gh repo clone kenjam97/dotfiles ~/dotfiles
   # work laptop only: clone the private overlay to ~/dotfiles-work
   ~/dotfiles/bootstrap-wsl.sh            # or GIT_EMAIL=you@example.com ~/dotfiles/bootstrap-wsl.sh
   ```
   The bootstrap ends with `dots-windows apply`, which drops in the Alacritty, GlazeWM and Zebar
   configs. Start Alacritty from then on instead of Windows Terminal (it opens WSL + tmux).
3. Follow the "Next" list it prints, then the admin steps below.

## Day to day

- Everything except the Windows-side configs is symlinked, so edits land in the repo directly.
- Edited a Windows config (GlazeWM/Zebar/Alacritty)? `dots-windows capture`, then commit.
- Pulled changes to `windows/`? `dots-windows apply`. `dots-windows diff` shows drift.
- Claude Code config is copied, not linked: diff `~/.claude/settings.json` against `claude/` now and then.

## Windows (manual, admin PowerShell)

```powershell
# Defender: don't scan the WSL disk
Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\wsl"

# GlazeWM at logon (needs elevation, so a scheduled task rather than a Run key)
$a = New-ScheduledTaskAction -Execute 'C:\Program Files\glzr.io\GlazeWM\glazewm.exe'
$t = New-ScheduledTaskTrigger -AtLogOn -User (whoami)
$p = New-ScheduledTaskPrincipal -UserId (whoami) -LogonType Interactive -RunLevel Highest
$s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
Register-ScheduledTask -TaskName 'GlazeWM' -Action $a -Trigger $t -Principal $p -Settings $s
```
